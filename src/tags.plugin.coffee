# Prepare
{TaskGroup} = require('taskgroup')

# Export
module.exports = (BasePlugin) ->
	# Define
	class TagsPlugin extends BasePlugin
		# Name
		name: 'tags'

		# Config
		config:
			relativePath: "tags"
			extension: ".html"
			helper: null

		# =============================
		# Events

		# Create tag pages
		parseAfter: (opts,next) ->
			# Prepare
			me = @
			config = @getConfig()
			docpad = @docpad
			docpadConfig = docpad.getConfig()
			database = docpad.getDatabase()

			# Log
			docpad.log('info', "Creating tag pages...")

			# Prepare the tasks
			tasks = new TaskGroup().setConfig(concurrency:0).once 'complete', (err) ->
				# Check
				return next(err)  if err

				# Log
				docpad.log('info', "Created #{tags.length} tag pages...")

				# Complete
				return next()

			# Prepare tag listing
			tags = {}

			# Cycle through documents that have tags
			docpad.getCollection('html').forEach (document) ->
				# Prepare
				documentTags = document.get('tags') or []
				return  if documentTags.length is 0

				# Add the document tags to the index
				for documentTag in documentTags
					tags[documentTag] = true

			# Flatten the tags
			tags = Object.keys(tags)

			# Inject the tag documents
			tags.forEach (tag) ->  tasks.addTask (complete) ->
				# Prepare
				documentOpts = {}

				# Meta
				documentOpts.meta =
					title: "Tag: #{tag}"
					tag: tag
					relativePath: "#{config.relativePath}/#{tag}#{config.extension}"

				# Data
				documentOpts.data = ''

				# Create document from attributes
				document = docpad.createDocument(null, documentOpts)

				# Inject helper
				config.helper?.call(me, document)

				# Load the document
				document.load (err) ->
					# Check
					return complete(err)  if err

					# Add it to the database
					opts.collection?.add(document)
					database.add(document)

					# Complete
					return complete()

			# Run
			tasks.run()

			# Chain
			@

	###
	writeFiles: (opts,next) ->
		if @getConfig().writeSourcEfiles
			.writeSource()
	###