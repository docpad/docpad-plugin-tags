# Prepare
{TaskGroup} = require('taskgroup')
eachr = require('eachr')
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
			relativePath: "tumblr"
			extension: ".html"

		# Fetch our Tumblr Posts
		# next(err,data), data = {tumblrPosts,tumblrTags}
		fetchTumblrData: (opts={},next) ->
			# Prepare
			config = @getConfig()

			# Check
			if !config.blog or !config.apiKey
				err = new Error('Tumblr plugin is not configured correctly')
				return next(err)

			# Prepare
			{blog,apiKey} = config
			blog = blog+'.tumblr.com'  if blog.indexOf('.') is -1

			# Prepare
			tumblrUrl = "http://api.tumblr.com/v2/blog/#{blog}/posts?api_key=#{escape apiKey}"
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
					return next(null, data)

			# Chain
			@


		# =============================
		# Events

		# Populate Collections
		# Import Tumblr Data into the Database
		populateCollections: (opts,next) ->
			# Prepare
			config = @getConfig()
			docpad = @docpad
			database = docpad.getDatabase()
			docpadConfig = docpad.getConfig()

			# Log
			docpad.log('info', "Importing Tumblr...")

			# Fetch
			@fetchTumblrData null, (err,data) ->
				# Check
				return next(err)  if err

				# Prepare
				tasks = new TaskGroup().once('complete', next)
				{tumblrPosts,tumblrTags} = data

				# Inject our posts
				eachr tumblrPosts, (tumblrPost) ->  tasks.addTask (complete) ->
					# Prepare
					opts = {}

					# Meta
					opts.meta =
						tumblr: tumblrPost
						title: tumblrPost.title or null
						date: new Date(tumblrPost.date)
						relativePath: "#{config.relativePath}/#{tumblrPost.type}/#{tumblrPost.id}#{config.extension}"

					# Data
					opts.data = tumblrPost.body or ''  # TODO: should we need the or ''
					delete tumblrPost.body

					# Create document from attributes
					document = docpad.createDocument(null, opts)

					# Add it to the database
					database.add(document)

					# Complete
					return complete()

				# Execute tasks
				tasks.run()

			# Chain
			@

	###
	writeFiles: (opts,next) ->
		if @getConfig().writeSourcEfiles
			.writeSource()
	###