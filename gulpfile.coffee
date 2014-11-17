gulp    = require 'gulp'
coffee  = require 'gulp-coffee'
mocha   = require 'gulp-mocha'
replace = require 'gulp-replace'
rename  = require 'gulp-rename'
gutil   = require 'gulp-util'
rjs     = require 'gulp-requirejs'
fs      = require 'fs'
path    = require 'path'

gulp.task 'build', () ->
	gulp.src 'src/**/*.coffee'
	.pipe coffee()
	.pipe gulp.dest('lib')

gulp.task 'test', ['build'], () ->
	# Bootstrap test environment (mainly require.js)
	require('./test/main.coffee')
	# Load rest of the test files.
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

gulp.task 'dist', ['build', 'test', 'change version'], () ->
	opts =
		baseUrl: "lib"
		paths:
			capacitor: "main"
			signals: "../node_modules/signals/dist/signals"
		include: ["../vendor/almond", 'main']
		nodeRequire: require
		out: "capacitor.js"
		wrap:
			startFile: "build/wrap-start.js"
			endFile: "build/wrap-end.js"

	rjs opts
	.pipe gulp.dest 'dist/'

