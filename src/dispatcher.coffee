invariant = require './invariant'
{Signal}  = require 'signals'

'use strict'

module.exports = new class Dispatcher

	###
	# @var {boolean} dispatching Wether or not the dispatcher is currently dispatching.
	# @private
	###
	dispatching = no
	###
	# @var {integer} storeID ID to use for the next store that gets registered.
	# @private
	###
	storeID = 0

	###
	# @var {object} stores Store registry.
	# @private
	###
	stores = {}
	###
    # @var {object} isPending Object for tracking pending store callbacks.
	# @private
	###
	isPending = {}
	###
    # @var {object} isPending Object for tracking handled store callbacks.
	# @private
	###
	isHandled = {}

	###
    # @var {string} isPending The current action being dispatched, if any.
	# @private
	###
	currentAction = null

	###
    # @var {object} Signal triggered when the dispatcher is started.
	# @public
	###
	started: new Signal()
	###
    # @var {object} Signal triggered when the dispatcher is stopped.
	# @public
	###
	stopped: new Signal()

	###
    # Sets the dispatcher to a state where all stores are neither
    # pending nor handled.
    #
	# @private
	###
	prepareForDispatching = () ->
		dispatching = yes

		for id of stores
			isPending[id] = no
			isHandled[id] = no

		@started.dispatch()

	###
    # Resets the dispatcher state after dispatching.
    #
	# @private
	###
	finalizeDispatching = () ->
		currentAction = null
		dispatching = no

		@stopped.dispatch()

	###
    # Calls the action handler on a store with the current action and payload.
    # This method is used when dispatching.
    #
    # @param {integer} id The ID of the store to notify
	# @private
	###
	notifyStore = (id) ->
		invariant currentAction?,
			"Cannot notify store without an action"

		isPending[id] = yes
		stores[id]._handleAction.call stores[id], currentAction, @waitFor
		isHandled[id] = yes

	###
    # Registers a store with the dispatcher so that it's notified when actions
    # are dispatched.
    #
    # @param {Object} store The store to register with the dispatcher
    ###
	register: (store) ->
		stores[storeID] = store
		store._id = storeID++;


	###
    # Unregisters a store from the dispatcher so that it's no longer
    # notified when actions are dispatched.
    #
    # @param {Object} store The store to unregister from the dispatcher
    ###
	unregister: (store) ->
		invariant store._id? and stores[store._id]?,
			"dispatcher.unregister(...): Store is not registered with the dispatcher."
		delete stores[store._id]

	###
    # Method for waiting for other stores to complete their handling
    # of actions. This method is passed along to the Stores when an action
    # is dispatched.
    #
    # @see notifyStore
    ###
	waitFor: (storeDependencies...) =>
		# We can only wait for dependencies if the dispatcher is dispatching.
		# In other words, waitFor() has to be called inside an action handler.
		invariant dispatching, """
			dispatcher.waitFor(): It's not possible to wait for dependencies when the dispatcher isn't dispatching.
			waitFor() should be called in an action handler.
			"""

		# Find dependencies with an unhandled action.
		for dependency in storeDependencies
			id = dependency._id

			# The dependency should be registered with the dispatcher
			invariant id? and stores[id]?,
				'dispatcher.waitFor(...): dependency is not registered with the dispatcher.'

			if isPending[id]
				# if a dependency (B) of caller (A) is pending but not handled, that dependency (B) has a waitFor that depends
				# on the caller (A). In other words, there's a circular dependency.
				invariant isHandled[id],
					'dispatcher.waitFor(...): Circular dependency detected.'

				continue

			# Make the dependency handle the action.
			notifyStore.call @, id

	###
    # Method for dispatching in action. This method is used by the Action class
    # when calling Action.dispatch().
    #
    # @param {string} actionName The name of the action to dispatch
    # @param {mixed} payload The payload for the event.
    ###
	dispatch: (actionInstance) =>
		# The flux architecture dictates that an action cannot
		# immediately trigger another action, which leads to cascading
		# updates and possibly infinite loops.
		invariant !dispatching,
			'dispatcher.dispatch(...): Cannot dispatch in the middle of a dispatch.'

		currentAction = actionInstance

		prepareForDispatching.call @

		try
			for id of stores
				continue if isPending[id]
				notifyStore.call @, id
		finally
			finalizeDispatching.call @
