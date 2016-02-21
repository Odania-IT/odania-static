# Odania Static

This module provides static content to the Odania Portal

## Structure of the static content

.
+-- contents
|   +-- _general
|       +-- _general
|            +-- assets
|                +-- image.png
|            +-- web
|                +-- de
|                    +-- imprint.md
|   +-- example.com
|       +-- _general
|            +-- assets
|                +--favicon.ico
|       +-- www
|            +-- web
|                +-- de
|                    +-- index.md
|                    +-- handy.html
|       +-- domain-config.json
|   +-- config.json


## example config.json

{
	"plugin-config": {
		"name": "static-content",
		"default": true,
		"author": [
			"Mike Petersen <mike@odania-it.com>"
		],
		"url": "http://www.odania.com"
	},
	"config": {
		"title": "My awesome example title",
		"layout": "simple"
	},
	"domains": {
		"_general": {
			"config": {
			},
			"redirects": {
				"^example.com$": "www.example.com"
			},
			"default_subdomains": {
				"_general": "www"
			}
		}
	}
}


## TODO

(http://www.odania.com/en/todo.html)[http://www.odania.com/en/todo.html]
