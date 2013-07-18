module.exports =
	plugins:
		tags:
			helper: (document) ->
				document.setMetaDefaults(
					layout: 'tag'
				)
				###
				.set(
					writeSource: true
					fullPath: @docpad.getConfig().srcPath+'/documents/'+document.get('relativePath')
				)
				###