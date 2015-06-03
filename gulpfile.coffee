gulp     = require 'gulp'
mocha    = require 'gulp-mocha'
replace  = require 'gulp-replace'
rename   = require 'gulp-rename'
gutil    = require 'gulp-util'
fs       = require 'fs'
path     = require 'path'
webpack  = require 'webpack'
exec     = require('child_process').exec
coffee   = require 'gulp-coffee'
jsdoc2md = require 'gulp-jsdoc-to-markdown'

gulp.task 'test', () ->
	# Load and run the test files.
	gulp.src ['test/!(integration).coffee', 'test/integration.coffee']
	.pipe mocha	reporter: 'spec'

gulp.task 'change version', () ->
	throw new Error("Version parameter is required") unless gutil.env.version?
	version = gutil.env.version

	# Replace version in package.json
	pkg = fs.readFileSync path.join __dirname, "package.json"
	pkg = JSON.parse pkg
	pkg.version = version
	pkg = JSON.stringify pkg, null, 2
	fs.writeFileSync path.join(__dirname, "package.json"), pkg

	# Replace version in wrap files
	gulp.src 'build/*.template'
	.pipe replace "{CAPACITOR_VERSION}", version
	.pipe rename extname: ".js"
	.pipe gulp.dest "build/"

gulp.task 'generate docs', (callback) ->
	gulp.src 'src/**/*.coffee'
	.pipe coffee bare: yes
	.pipe jsdoc2md private: true
	.on 'error', (err) ->
		gutil.log gutil.colors.red err.message
	.pipe rename extname: ".md"
	.pipe gulp.dest 'docs/api'


gulp.task 'compile distributable', ['test', 'change version'], (callback) ->

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

gulp.task 'dist', ['compile distributable', 'generate docs'], (callback) ->
	throw new Error("Version parameter is required") unless gutil.env.version?
	exec "git status --porcelain", (err, stdout) ->
		files = stdout.split('\n')
		files = files.slice 0, -1
		if files.length > 2
			throw new gutil.PluginError 'git', "You're in a dirty working copy, please do something about that."

		for file in files when file.indexOf('package.json') is -1 and file.indexOf('dist/capacitor.js') is -1
			throw new gutil.PluginError 'git', "You're in a dirty working copy, please do something about that."

		exec "git add . && git commit -m 'v#{gutil.env.version}' ", (err, stdout) ->

			gutil.log gutil.colors.green "Version #{gutil.env.version} has been committed"

			# Beware: if you write stupid things such as '; rm -rf /;' in --version, you're gonna have a bad time..
			exec "git tag -a v#{gutil.env.version} -m 'published version #{gutil.env.version}'", (err, stdout) ->
				throw err if err?
				gutil.log gutil.colors.green "Version #{gutil.env.version} has been tagged"
