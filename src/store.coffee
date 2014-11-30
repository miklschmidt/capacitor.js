define [
	'lodash'
	'signals'
	'action'
	'dispatcher'
	'invariant'
], (_, {Signal}, Action, dispatcher, invariant) ->

	###
	#	implementation example:
	#
	#	class TodoStore extends Store
	#		@action someAction, () ->
	#			@doStuff()
	#			@doOtherStuff()
	#			@profit()
	#
	#		doStuff: () ->
	#			# Do things..
	#
	#
	#		doOtherStuff: () ->
	#			# Do things..
	#
	#		profit: () ->
	#			# Do things..
	#			@changed.dispatch()
	###

	class Store

		###
		# @static
		# @private
		###
		@_handlers: null

		###
		# @private
		###
		_properties: null


		###
		# Static method for defining action handlers on a Store.
		#
		# @static
		# @param {Action} action The Action to associated with the handler.
		# @param {Function} fn The handler to call when Action is triggered.
		###
		@action: (action, fn) ->
			@_handlers ?= {}
			invariant action instanceof Action and typeof fn is "function",
				"""
				Store.action(...): Provided action should be created via the action manager and a handler must be given as a second parameter.
				If you're trying to reference a prototype method, don't do that.
				"""
			invariant !@_handlers[action]?,
				"Store.action(...): You can only define one handler pr action"

			@_handlers[action] = fn

			# Check if the function is a reference to a prototype method, and warn.
			for own prop of (@::) when fn is @::[prop]
				console.warn """
					Store.action(...): Action %s is referring to a method on the store prototype (%O).
					This is bad practice and should be avoided.
					The handler itself may call prototype methods,
					and is called with the store instance as context for that reason.
					""", action, @

		###
		# Constructor function that sets up actions and events on the store
		###
		constructor: () ->
			dispatcher.register(@)
			@_properties = {}

			# Set up change event.
			@changed = new Signal

			# Call initialize, if it's there.
			@initialize?()


		get: (name) ->
			val = null
			if name?
				invariant _.isString(name) or _.isArray(name), "Store.get(...): first parameter should be undefined, a string, or an array of keys."
				val = _.pick @_properties, name
				val = val[name] if _.isString(name)
				val = _.cloneDeep val if _.isObject(val)
			else
				val = _.cloneDeep @_properties
			return val

		set: (name, val) ->
			invariant _.isObject(name) or _.isString(name) and val?,
				"""
					Store.set(...): You can only set an object or pass a string and a value.
					Use Store.unset(#{name}) to unset the property.
				"""
			if _.isString(name)
				properties = {}
				properties[name] = val
			if _.isObject(name)
				properties = name
			newProps =  _.cloneDeep properties
			_.assign @_properties, newProps

			@changed.dispatch 'set', newProps

			return @

		merge: (name, val) ->
			if _.isString(name)
				properties = {}
				properties[name] = val
			if _.isObject(name)
				properties = name
			newProps =  _.cloneDeep properties
			_.merge @_properties, newProps

			changedProps = _.pick @_properties, _.keys(newProps)
			@changed.dispatch 'merge', changedProps

			return @

		unset: (name) ->
			invariant _.isString(name), "Store.unset(...): first parameter must be a string."
			delete @_properties[name] if @_properties[name]?
			@changed.dispatch 'unset', name
			return @


		###
		# Method for calling handlers on the store when an action is executed.
		#
		# @param {string} actionName The name of the executed action
		# @param {mixed} payload The payload passed to the handler
		# @param {array} waitFor An array of other signals to wait for in this dispatcher run.
		###
		_handleAction: (actionName, payload, waitFor) =>
			invariant @constructor._handlers[actionName],
				"Store._handleAction(...): Store has no handler associated with #{actionName}"

			# Call the handler with the context of this store instance
			@constructor._handlers[actionName].call @, payload, waitFor
