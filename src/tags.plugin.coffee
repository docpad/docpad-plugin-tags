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
			relativeDirPath: "tags"
			extension: ".json"
			injectDocumentHelper: null
			collectionName: "tags"
			findCollectionName: "database"

		# =============================
		# Events

		# Extend Collections
		# Create our live collection for our tags
		extendCollections: ->
			# Prepare
			config = @getConfig()
			docpad = @docpad
			database = docpad.getDatabase()

			# Check
			if config.collectionName
				# Create the collection
				tagsCollection = database.findAllLive({relativeDirPath: $startsWith: config.relativeDirPath}, [title:1])

				# Set the collection
				docpad.setCollection(config.collectionName, tagsCollection)

			# Chain
			@

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
			docpad.getCollection(config.findCollectionName).forEach (document) ->
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
				tagName = tag.toLowerCase().replace(/[^a-z0-9]/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '')
				documentAttributes =
					data: JSON.stringify({tag}, null, '\t')
					meta:
						title: "Tag: #{tag}"
						tag: tag
						tagName: tag
						url: "#{config.relativeDirPath}/#{tag}#{config.extension}"
						relativePath: "#{config.relativeDirPath}/#{tagName}#{config.extension}"

				# Create document from attributes
				document = docpad.createDocument(documentAttributes)

				# Inject helper
				config.injectDocumentHelper?.call(me, document)

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