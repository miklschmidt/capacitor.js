gulp    = require 'gulp'
coffee  = require 'gulp-coffee'
mocha   = require 'gulp-mocha'
replace = require 'gulp-replace'
rename  = require 'gulp-rename'
gutil   = require 'gulp-util'
fs      = require 'fs'
path    = require 'path'
webpack = require 'webpack'

gulp.task 'build', () ->
	gulp.src 'src/**/*.coffee'
	.pipe replace "\t", "  " # fix JSDoc output from coffee
	.pipe coffee()
	.pipe gulp.dest('lib')

gulp.task 'test', ['build'], () ->
	# Load and run the test files.
	gulp.src 'test/*.coffee'
	.pipe mocha	reporter: 'spec'

gulp.task 'default', ['build']

gulp.task 'change version', () ->
	throw new Error("Version parameter is required") unless gutil.env.version?
	version = gutil.env.version

	# Replace version in package.json
	pkg = fs.readFileSync path.join __dirname, "package.json"
	pkg = JSON.parse pkg
	pkg.version = version
	pkg = JSON.stringify pkg, null, 2
	fs.writeFileSync path.join(__dirname, "package.json"), pkg

	# Replace version in r.js wrap files
	gulp.src 'build/*.template'
	.pipe replace "{CAPACITOR_VERSION}", version
	.pipe rename extname: ".js"
	.pipe gulp.dest "build/"

gulp.task 'dist', ['build', 'test', 'change version'], (callback) ->

	compiler = webpack require('./webpack.config')
	.run (err, stats) ->
		if err
			gutil.beep()
			gutil.log err
			return
		fileStart = fs.readFileSync path.join __dirname, 'build', 'wrap-start.js'
		file = fs.readFileSync path.join __dirname, 'dist', 'capacitor.js'
		content = fileStart + file
		fs.writeFileSync path.join(__dirname, 'dist', 'capacitor.js'), content
		gutil.log 'compilation complete :)'
		callback()

	null

