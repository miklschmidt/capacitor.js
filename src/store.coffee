define [
	'signals'
	'action'
	'dispatcher'
	'invariant'
], ({Signal}, Action, dispatcher, invariant) -> 
	
	###
	#	implementation example:
	#
	#	class TodoStore extends Store
	#		actions: [
	#			someAction, () ->
	#				@doStuff()
	#				@doOtherStuff()
	#				@profit()
	#		]
	#
	#		doStuff: () ->
	#			# Do things..
	#			@changed.dispatch()
	#
	#
	#		doOtherStuff: () ->
	#			# Do things..
	#			@changed.dispatch()
	#
	#		profit: () ->
	#			# Do things..
	#			@changed.dispatch()
	###


	class Store

		###
		# Constructor function that sets up actions and events on the store
		###
		constructor: () ->
			dispatcher.register(@)
			@handlers = []
			invariant @actions?.length > 1,
				"Actions array should be an array of actions and handlers"
			for action, i in @actions by 2
				invariant action instanceof Action and typeof @actions[i+1] is "function",
					"""
					Action array is malformed: every second argument should be a function
					and follow and instance of Action.
					"""

				invariant !@_handlers[action]?,
					"You can only define one handler pr action"

				@_handlers[action] = @actions[i+1]

			# Set up change event.

			@changed = new Signal

			# Call initialize, if it's there.
			@initialize?()

		###
		# Method for calling handlers on the store when an action is executed.
		# 
		# @param {string} actionName The name of the executed action
		# @param {mixed} payload The payload passed to the handler
		# @param {array} waitFor An array of other signals to wait for in this dispatcher run.
		###
		_handleAction: (actionName, payload, waitFor) =>
			invariant @_handlers[actionName], 
				"Store has no handler associated with #{actionName}"

			# Call the handler with the context of this store instance
			@_handlers[actionName].call @, payload, waitfor
