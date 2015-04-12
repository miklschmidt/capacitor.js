dispatcher = require './dispatcher'
invariant = require './invariant'
Action = require './action'

_actionID = 0
_requestID = 0

class ActionInstance

	constructor: (@type, @payload) ->
		@actionID = _actionID++
		Object.freeze @

	valueOf: () ->
		@payload

	getActionID: () ->
		@actionID

module.exports = class ActionCreator

	###
	# Dispatches an action through the dispatcher
	#
	# @param {Action} action The action to dispatch
	# @param {mixed} payload Payload for the action
	###
	dispatch: (action, payload) ->
		actionInstance = @createActionInstance action, payload
		dispatcher.dispatch actionInstance
		return actionInstance

	###
	# Creates an action instance for dispatching
	#
	# @param {Action} action The action to dispatch
	# @param {mixed} payload Payload for the action
	###
	createActionInstance: (action, payload) ->
		invariant action instanceof Action and action?.type?, 
			"The action you dispatched does not seem to be an instance of capacitor.Action"
		new ActionInstance action.type, payload

	###
	# Generates a request id. Useful for tracking specific requests in components.
	###
	generateRequestID: () ->
		return _requestID++