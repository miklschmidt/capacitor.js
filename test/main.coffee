requirejs = require('requirejs')
path = require('path')

requirejs.config {
	baseUrl: path.join(__dirname, '..', 'lib')
	nodeRequire: require
}

# Set global vars used in tests

global.expect = require('chai').expect
global.sinon = require('sinon')
global.requirejs = requirejs