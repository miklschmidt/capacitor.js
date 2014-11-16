define () ->

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

	(condition, message) ->
		unless condition
			unless args.length
				error = new Error """
			        Minified exception occurred; use the non-minified dev environment
			        for the full error message and additional helpful warnings.
				"""
			else
				error = new Error message

			error.framesToPop = 1 # We don't care about invariant's own frame
			throw error