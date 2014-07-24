# Export
module.exports = (BasePlugin) ->
	latinize = require('latinize')
	# Define
	class TagsPlugin extends BasePlugin
		# Name
		name: 'tags'

		# Tags
		tags: null

		# Config
		config:
			relativeDirPath: "tags"
			extension: ".json"
			injectDocumentHelper: null
			collectionName: "tags"
			findCollectionName: "database"
			logLevel: 'info'

		# Setup tags object
		constructor: ->
			@tags ?= {}
			super


		# =============================
		# Events

		# Extend Collections
		# Create our live collection for our tags
		extendCollections: ->
			# Prepare
			plugin = @
			config = @getConfig()
			docpad = @docpad

			# Create the collections for the tags
			docpad.setCollection config.collectionName, docpad.getDatabase().findAllLive({
				relativeDirPath: $startsWith: config.relativeDirPath
			}, [title:1])

			# Listen for tags
			docpad.getCollection(config.findCollectionName).on 'add change:tags', (model) ->
				# Prepare
				tags = model.get('tags') or []
				tags = tags.split(/[\s,]+/)  if typeof tags is 'string'

				# Check
				return  if tags.length is 0

				# Add the document tags to the index
				for tag in tags
					plugin.tags[tag] ?= plugin.createTagDocument tag, (err) ->
						docpad.error(err)  if err

				# Complete
				return true

			# Chain
			@

		# Create Tag Document
		createTagDocument: (tag, next) ->
			# Prepare
			plugin = @
			config = @getConfig()
			docpad = @docpad

			# Fetch
			document = docpad.getFile({tag:tag})

			# Create
			tagName = latinize(tag).toLowerCase().replace(/[^a-z0-9]/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '')
			documentAttributes =
				data: JSON.stringify({tag}, null, '\t')
				meta:
					mtime: new Date()
					title: "Tag: #{tag}"
					tag: tag
					tagName: tag
					relativePath: "#{config.relativeDirPath}/#{tagName}#{config.extension}"

			# Existing document
			if document?
				document.set(documentAttributes)

			# New Document
			else
				# Create document from opts
				document = docpad.createDocument(documentAttributes)

			# Inject helper
			config.injectDocumentHelper?.call(plugin, document)

			# Load the document
			document.action 'load', (err) ->
				# Check
				return next(err)  if err

				# Add it to the database (with b/c compat)
				docpad.addModel?(document) or docpad.getDatabase().add(document)

				# Log
				docpad.log(config.logLevel, "Created tag page for #{tag} at #{document.getFilePath()}")

				# Complete
				return next()

			# Return the document
			return document
