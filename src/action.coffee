define [
	'dispatcher'
], (dispatcher) ->

	_id = 0

	class ActionInstance

		constructor: (@type, @payload) ->
			@actionID = _id++
			Object.freeze @

		valueOf: () ->
			@payload

		getActionID: () ->
			@actionID

	class Action

		###
		# Constructor
		#
		# @param {string} The name of the action
		###
		constructor: (@type) ->

		###
		# Method for dispatching the action through the dispatcher
		#
		# @param {mixed} Payload for the action
		###
		dispatch: (payload) ->
			actionInstance = @createActionInstance(payload)
			dispatcher.dispatch actionInstance
			return actionInstance

		createActionInstance: (payload) ->
			new ActionInstance @type, payload

		###
		# Magic method for coercing an action to a string
		###
		toString: () -> @type
