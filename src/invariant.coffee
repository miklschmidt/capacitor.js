define [
	'logger'
], (logger) ->

	###
	# Use invariant() to assert state which your program assumes to be true.
	#
	# Provided arguments are automatically type checked and logged correctly to the console
	# Chrome's console.log sprintf format.
	#
	# ex: invariant(!hasFired, "hasFired was expected to be true but was", hasFired)
	#
	# The invariant message will be stripped in production, but the invariant
	# will remain to ensure logic does not differ in production.
	###

	(condition, args...) ->
		unless condition
			unless args.length
				error = new Error """
			        Minified exception occurred; use the non-minified dev environment
			        for the full error message and additional helpful warnings.
				"""
			else
				if window?
					logger.error args...
					error = new Error "Invariant violation. See error message above (You are not supposed to catch these)."
				else
					error = new Error args.join(" ")
					
			error.framesToPop = 1 # We don't care about invariant's own frame
			throw error