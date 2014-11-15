define [
	'invariant'
	'signals'
], (invariant, {Signal}) ->

	'use strict'

	class Dispatcher

		###
		# @var {boolean} dispatching Wether or not the dispatcher is currently dispatching
		# @private
		###
		dispatching = no
		###
		# @var {integer} storeID ID to use for the next store that gets registered. 
		# @private
		###
		storeID = 0
		
		###
		# @var {object} stores
		# @private
		###
		stores = {}
		###
		# @private
		###
		isPending = {}
		###
		# @private
		###
		isHandled = {}

		###
		# @private
		###
		currentAction = null
		###
		# @private
		###
		currentPayload = null

		###
		# @public
		###
		started: new Signal()
		###
		# @public
		###
		stopped: new Signal()

		###
		# @private
		###
		prepareForDispatching = () ->
			dispatching = yes 

			for id of stores
				isPending[id] = no
				isHandled[id] = no

			@started.dispatch()

		###
		# @private
		###
		finalizeDispatching = () ->
			currentAction = null
			currentPayload = null
			dispatching = no

			@stopped.dispatch()

		###
		# @private
		###
		notifyStore = (id) ->
			invariant currentAction? and currentPayload?,
				"Cannot notify store without an action and a payload"

			isPending[id] = yes
			stores[id]._handleAction.call stores[id], currentAction, currentPayload, @waitFor
			isHandled[id] = yes

		register: (store) ->
			stores[storeID] = store
			store._id = storeID++;

		unregister: (store) ->
			invariant store._id? and stores[store._id]?,
				"dispatcher.unregister("
				store
				"):"
				store
				"is not registered with the dispatcher."
			delete stores[store._id]

		waitFor: (storeDependencies...) =>
			# We can only wait for dependencies if the dispatcher is dispatching.
			# In other words, waitFor() has to be called inside an action handler.
			invariant dispatching,
				'dispatcher.waitFor('
				storeDependencies
				"): It's not possible to wait for dependencies when the dispatcher isn't dispatching."
				"waitFor() should be called in an action handler."

			# Find dependencies with an unhandled action.
			for dependency in storeDependencies
				id = dependency._id

				# The dependency should be registered with the dispatcher
				invariant id? and stores[id]?,
					"dispatcher.waitFor("
					storeDependencies
					"):"
					dependency
					"is not registered with the dispatcher."

				if isPending[id]
					# if a dependency (B) of caller (A) is pending but not handled, that dependency (B) has a waitFor that depends 
					# on the caller (A). In other words, there's a circular dependency.
					invariant isHandled[id],
						'dispatcher.waitFor: ('
						storeDependencies
						'): Circular dependency detected while waiting for'
						dependency

					continue

				# Make the dependency handle the action.
				notifyStore.call @, id

		dispatch: (actionName, payload) =>
			# The flux architecture dictates that an action cannot 
			# immediately trigger another action, which leads to cascading 
			# updates and possibly infinite loops. 
			invariant !dispatching,
				'dispatcher.dispatch(',
				actionName, payload
				'): Cannot dispatch in the middle of a dispatch.'

			currentAction = actionName
			currentPayload = payload

			prepareForDispatching.call @

			try
				for id of stores
					continue if isPending[id]
					notifyStore.call @, id
			finally
				finalizeDispatching.call @


	return new Dispatcher()














