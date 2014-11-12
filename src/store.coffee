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
	#		events: [
	#			'changed'
	#			'deleted'
	#			'added'
	#			'startedFetching'
	#			'finishedFetching'
	#		]
	#
	#		doStuff: () ->
	#			@added.dispatch()
	#			@changed.dispatch()
	#
	#
	#		doOtherStuff: () ->
	#			@deleted.dispatch()
	#
	#		profit: () ->
	#			@startedFetching.dispatch()
	#			setTimeout () =>
	#				@finishedFetching.dispatch()
	#			, 3000
	###


	class Store

		###
		# Constructor function that sets up actions and events on the store
		###
		constructor: () ->
			dispatcher.register(@)
			@handlers = []
			for action, i in @actions by 2
				invariant action instanceof Action and typeof @actions[i+1] is "function",
					"Action array is malformed: every second argument should be a function"
					"and follow and instance of Action"
					@actions

				invariant !@_handlers[action]?,
					"You can only define one handler pr action"

				@_handlers[action] = @actions[i+1]

			for eventName in @events
				invariant typeof eventName is "string", 
					"Event array is malformed"
					@events

				invariant !@[eventName]?, 
					"There's already a property or method with the name"
					eventName,
					"on"
					@,
					"This error is usually due to improper naming."
					"Event names should be past tense, methods should be present tense."

				@[eventName] = new Signal

		###
		# Method for calling handlers on the store when an action is executed.
		# 
		# @param {string} actionName The name of the executed action
		# @param {mixed} payload The payload passed to the handler
		# @param {array} waitFor An array of other signals to wait for in this dispatcher run.
		###
		_handleAction: (actionName, payload, waitFor) =>
			invariant @_handlers[actionName], 
				"No handler associated with"
				actionName
				"on"
				@

			# Call the handler with the context of this store instance
			@_handlers[actionName].call @, payload, waitfor
