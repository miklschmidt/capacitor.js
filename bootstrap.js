var requirejs = require('requirejs');
var path = require('path');

requirejs.config({
	baseUrl: path.join(__dirname, 'lib'),
	nodeRequire: require
});

module.exports = requirejs("./lib/main");