gulp = require 'gulp'
coffee = require 'gulp-coffee'
mocha = require 'gulp-mocha'

gulp.task 'build', () ->
	gulp.src 'src/**/*.coffee'
	.pipe coffee()
	.pipe gulp.dest('lib')

gulp.task 'test', ['build'], () ->
	# Bootstrap test environment
	require('./test/main.coffee')
	# Load rest of the test files.
	gulp.src ['test/*.coffee']
	.pipe mocha	reporter: 'spec'
	.on 'error', (err) ->
		throw err

gulp.task 'default', ['build']