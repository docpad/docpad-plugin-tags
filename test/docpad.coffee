module.exports =
	plugins:
		tags:
			injectDocumentHelper: (document) ->
				document
					.setMeta(
						layout: 'tag'
					)
###
					.set(
						writeSource: true
						fullPath: @docpad.getPath('source')+'/documents/'+document.get('relativePath')
					)
###
