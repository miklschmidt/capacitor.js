describe 'Integration Testing', () ->

	fs = require 'fs'
	path = require 'path'
	files = fs.readdirSync path.join __dirname, 'integration'
	require(path.join __dirname, 'integration', file) for file in files