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
						fullPath: @docpad.getConfig().srcPath+'/documents/'+document.get('relativePath')
					)
###