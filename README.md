# Tags Plugin for [DocPad](http://docpad.org)

<!-- BADGES/ -->

[![Build Status](http://img.shields.io/travis-ci/docpad/docpad-plugin-tags.png?branch=master)](http://travis-ci.org/docpad/docpad-plugin-tags "Check this project's build status on TravisCI")
[![NPM version](http://badge.fury.io/js/docpad-plugin-tags.png)](https://npmjs.org/package/docpad-plugin-tags "View this project on NPM")
[![Gittip donate button](http://img.shields.io/gittip/docpad.png)](https://www.gittip.com/docpad/ "Donate weekly to this project using Gittip")
[![Flattr donate button](http://img.shields.io/flattr/donate.png?color=yellow)](http://flattr.com/thing/344188/balupton-on-Flattr "Donate monthly to this project using Flattr")
[![PayPayl donate button](http://img.shields.io/paypal/donate.png?color=yellow)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QB8GQPZAH84N6 "Donate once-off to this project using Paypal")

<!-- /BADGES -->


Create tag pages within DocPad


## Install

```
docpad install tags
```


## Configuration

### Customising the Output

The default directory for where the imported documents will go inside is the `tags` directory. You can customise this using the `relativeDirPath` plugin configuration option.

The default extension for imported documents is `.json`. You can customise this with the `extension` plugin configuration option.

The default content for the imported documents is the serialised tag data as JSON data. You can can customise this with the `injectDocumentHelper` plugin configuration option which is a function that takes in a single [Document Model](https://github.com/bevry/docpad/blob/master/src/lib/models/document.coffee).

If you would like to render a partial for the imported document, add a layout, and change the extension, you can this with the following plugin configuration:

``` coffee
extension: '.html.eco'
injectDocumentHelper: (document) ->
	document.setMeta(
		layout: 'default'
		data: """
			<%- @partial('content/tag', @) %>
			"""
	)
```

You can find a great example of this customisation within the [syte skeleton](https://github.com/docpad/syte.docpad) which combines the tags plugin with the [partials plugin](http://docpad.org/plugin/partials) as well as the [tumblr plugin](http://docpad.org/plugin/tumblr) and [paged plugin](http://docpad.org/plugin/paged).


### Creating a File Listing

As imported documents are just like normal documents, you can also list them just as you would other documents. Here is an example of a `index.html.eco` file that would output the titles and links to all the imported tag documents:

``` erb
<h2>Tags:</h2>
<ul><% for file in @getFilesAtPath('tags/').toJSON(): %>
	<li>
		<a href="<%= file.url %>"><%= file.title %></a>
	</li>
<% end %></ul>
```


<!-- HISTORY/ -->

## History
[Discover the change history by heading on over to the `HISTORY.md` file.](https://github.com/docpad/docpad-plugin-tags/blob/master/HISTORY.md#files)

<!-- /HISTORY -->


<!-- CONTRIBUTE/ -->

## Contribute

[Discover how you can contribute by heading on over to the `CONTRIBUTING.md` file.](https://github.com/docpad/docpad-plugin-tags/blob/master/CONTRIBUTING.md#files)

<!-- /CONTRIBUTE -->


<!-- BACKERS/ -->

## Backers

### Maintainers

These amazing people are maintaining this project:

- Benjamin Lupton <b@lupton.cc> (https://github.com/balupton)

### Sponsors

No sponsors yet! Will you be the first?

[![Gittip donate button](http://img.shields.io/gittip/docpad.png)](https://www.gittip.com/docpad/ "Donate weekly to this project using Gittip")
[![Flattr donate button](http://img.shields.io/flattr/donate.png?color=yellow)](http://flattr.com/thing/344188/balupton-on-Flattr "Donate monthly to this project using Flattr")
[![PayPayl donate button](http://img.shields.io/paypal/donate.png?color=yellow)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QB8GQPZAH84N6 "Donate once-off to this project using Paypal")

### Contributors

These amazing people have contributed code to this project:

- Benjamin Lupton <b@lupton.cc> (https://github.com/balupton) - [view contributions](https://github.com/docpad/docpad-plugin-tags/commits?author=balupton)

[Become a contributor!](https://github.com/docpad/docpad-plugin-tags/blob/master/CONTRIBUTING.md#files)

<!-- /BACKERS -->


<!-- LICENSE/ -->

## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; 2013+ Bevry Pty Ltd <us@bevry.me> (http://bevry.me)

<!-- /LICENSE -->


