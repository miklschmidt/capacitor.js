dispatcher = require './dispatcher'
invariant = require './invariant'
Action = require './action'

_id = 0

class ActionInstance

	constructor: (@type, @payload) ->
		@actionID = _id++
		Object.freeze @

	valueOf: () ->
		@payload

	getActionID: () ->
		@actionID

module.exports = class ActionCreator

	###
	# Method for dispatching an action through the dispatcher
	#
	# @param {Action} action The action to dispatch
	# @param {mixed} payload Payload for the action
	###
	dispatch: (action, payload) ->
		actionInstance = @createActionInstance action, payload
		dispatcher.dispatch actionInstance
		return actionInstance

	createActionInstance: (action, payload) ->
		invariant action instanceof Action and action?.type?, 
			"The action you dispatched does not seem to be an instance of capacitor.Action"
		new ActionInstance action.type, payload
