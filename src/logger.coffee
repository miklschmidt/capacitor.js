define ->
	'use strict'

	class Logger

		determineType: (variable) ->
			part = Object.prototype.toString.apply(variable)
			type = part.substring(8, part.length-1).toLowerCase()
			# Handle HTML elements
			if type.indexOf('html') is 0
				type = 'dom'

			# Handle numbers
			if type is 'number' and isFinite(variable) and arg%1 isnt 0
				type = 'float'
			else
				type = 'integer'
			return type

		composeFormatString: (args) ->
			formats = []
			for arg in args
				switch @determineType(arg)
					when 'string'
						formats.push '%s'
					when 'float'
						formats.push '%f'
					when 'dom'
						formats.push '%o'
					else
						formats.push '%O'
			return formats.implode ' '

		write: (method, args) ->
			throw new Error "Console does not support #{method}" unless console[method]?
			if window? and not process?.versions?.node?
				# We're in browserland, use the string format for browsers.
				args.shift @composeFormatString args
			console[method].apply console, args

		error: (args...) -> @write 'error', args

		log: (args...) -> @write 'log', args

		warn: (args...) -> @write 'warn', args

		trace: (args...) -> @write 'trace', args

	return new Logger
