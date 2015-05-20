webpack = require 'webpack'

module.exports =
	entry: [
		'./src/main'
	]
	debug: false
	output:
		path: __dirname + '/dist/'
		filename: 'capacitor.js'
		libraryTarget: 'umd'
		library: 'capacitor'
	externals: ['lodash', 'immutable']
	plugins: [
		new webpack.NoErrorsPlugin()
	]
	moduleDirectories: ['node_modules']
	resolve:
		extensions: ['', '.js', '.coffee']
	module:
		loaders: [
			{test: /\.coffee/, loaders: ['coffee']}
		]
