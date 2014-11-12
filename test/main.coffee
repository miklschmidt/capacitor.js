requirejs = require('requirejs')
path = require('path')

requirejs.config {
	baseUrl: path.join(__dirname, '..', 'src')
	nodeRequire: require
}

