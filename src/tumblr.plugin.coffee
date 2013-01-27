# Prepare
balUtil = require('bal-util')
feedr = new (require('feedr').Feedr)

# Export
module.exports = (BasePlugin) ->
	# Define
	class TumblrPlugin extends BasePlugin
		# Name
		name: 'tumblr'

		# Config
		config:
			blog: process.env.TUMBLR_BLOG
			apiKey: process.env.TUMBLR_API_KEY
			writeSource: true
			relativePath: "tumblr"
			extension: ".html"

		# Fetch our Tumblr Posts
		# next(err,data), data = {tumblrPosts,tumblrTags}
		fetchTumblrData: (opts={},next) ->
			# Prepare
			config = @config

			# Check
			if !config.blog or !config.apiKey
				err = new Error('Tumblr plugin is not configured correctly')
				return next(err)

			# Prepare
			tumblrUrl = "http://api.tumblr.com/v2/blog/#{config.blog}/posts?api_key=#{escape config.apiKey}"
			tumblrPosts = []
			tumblrTags = []

			# Read feeds
			feedr.readFeed tumblrUrl, (err,feedData) ->
				# Check
				return next(err)  if err

				# Concat the posts
				for tumblrPost in feedData.response.posts
					tumblrPosts.push(tumblrPost)

				# Fetch the remaining posts
				totalPosts = feedData.response.blog.posts
				feeds = []
				for offset in [20...totalPosts] by 20
					feeds.push("#{tumblrUrl}&offset=#{offset}")
				feedr.readFeeds feeds, (err,feedsData) ->
					# Check
					return next(err)  if err

					# Concat the posts
					for feedData in feedsData
						for tumblrPost in feedData.response.posts
							tumblrPosts.push(tumblrPost)

					# Concat the tags
					for tag in (tumblrPosts.tags or [])
						unless tag in tumblrTags
							tumblrTags.push(tag)

					# Done
					data = {tumblrPosts,tumblrTags}
					return next(null,data)

			# Chain
			@


		# =============================
		# Events

		# Generate Before
		# Import Tumblr Data into the Database
		generateBefore: (opts,next) ->
			# Prepare
			docpad = @docpad
			config = @config
			tasks = new balUtil.Group(next)

			# Skip if we are doing a differential generate
			return next()  if opts.reset is false

			# Log
			docpad.log('info', "Importing Tumblr...")

			# Fetch
			@fetchTumblrData null, (err,data) ->
				# Check
				return next(err)  if err

				# Prepare
				{tumblrPosts,tumblrTags} = data

				# Inject our posts
				balUtil.each tumblrPosts, (tumblrPost) ->  tasks.push (complete) ->
					# Prepare
					date = new Date(tumblrPost.date)
					dateTime = date.getTime()
					dateString = date.toString()
					filename = "#{tumblrPost.id}#{config.extension}"
					fileRelativePath = "#{config.relativePath}/#{tumblrPost.type}/#{filename}"
					fileFullPath = docpad.getConfig().documentsPaths[0]+"/#{fileRelativePath}"

					# Merge
					attributes =
						meta: tumblrPost
						data: tumblrPost.body or 'blah'
						date: date
						filename: filename
						relativePath: fileRelativePath
						fullPath: fileFullPath

					# Create document from attributes
					document = docpad.ensureDocument(attributes)

					# Load the document
					docpad.loadDocument document, (err) ->
						# Check
						return complete(err)  if err

						# Write source
						if config.writeSource
							return document.writeSource(complete)
						else
							return complete()

				# Execute tasks
				tasks.run()

			# Chain
			@
