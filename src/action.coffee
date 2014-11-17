define [
	'dispatcher'
], (dispatcher) ->

	class Action

		###
		# Constructor
		# 
		# @param {string} The name of the action
		###
		constructor: (@name) ->

		###
		# Method for dispatching the action through the dispatcher
		#
		# @param {mixed} Payload for the action
		###
		dispatch: (payload) -> dispatcher.dispatch @name, payload

		###
		# Magic method for coercing an action to a string
		###
		toString: () -> @name