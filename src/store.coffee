_          = require 'lodash'
{Signal}   = require 'signals'
Action     = require './action'
dispatcher = require './dispatcher'
invariant  = require './invariant'
Immutable  = require 'immutable'

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

cloneDeep = (obj) ->
	return obj unless _.isObject(obj) or _.isArray(obj)
	if window?
		return obj if obj instanceof window.Element # Don't clone DOMnodes
	if obj instanceof Date
		return new Date(obj.getTime())
	newObj = null
	if _.isObject(obj) and not _.isArray(obj)
		newObj = {}
		if obj.clone? and typeof obj.clone is 'function'
			newObj = obj.clone()
		else
			for own key, val of obj
				if _.isObject(val) or _.isArray(val)
					newObj[key] = cloneDeep(val)
				else
					newObj[key] = val
	else
		newObj = []
		if obj.clone? and typeof obj.clone is 'function'
			newObj = obj.clone()
		else
			newObj.push cloneDeep(val) for val in obj
	return newObj

module.exports = class Store

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
	# @private
	###
	_currentActionInstance: null
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
		@_properties = Immutable.Map()

		# Set up change event.
		@changed = new Signal

		# Call initialize, if it's there.
		@initialize?()

		# Return proxy object used to interact with this store
		return @getInterface()

	###
	# Override this to change which methods are available to consumers.
	# NOTE: Remember that nothing but the store itself should be able to change the data in the store.
	###
	getInterface: () ->
		if @getProxyObject? and @getProxyObject isnt Store::getProxyObject
			console.warn "Store.getProxyObject() is deprecated use Store.getInterface()"
		return {
			get: @get.bind(@)
			getIn: @getIn.bind(@)
			@changed
			_id: @_id
		}

	getProxyObject: () ->
		return @getInterface()

	getIn: () ->
		return @_properties.getIn arguments...

	get: (name) ->
		val = null
		if name?
			invariant _.isString(name) or _.isArray(name), "Store.get(...): first parameter should be undefined, a string, or an array of keys."

			if _.isArray(name)
				val = @_properties.filter (val, key) -> key in name
			else if _.isString(name)
				val = @_properties.get name
		else
			val = @_properties
		return val

	set: (name, val) ->
		invariant _.isObject(name) or _.isString(name) and val?,
			"""
				Store.set(...): You can only set an object or pass a string and a value.
				Use Store.unset(#{name}) to unset the property.
			"""

		if _.isString(name)
			value = Immutable.fromJS val
			@_properties = @_properties.set name, Immutable.fromJS(value)

		if _.isObject(name)
			value = Immutable.fromJS name
			@_properties = Immutable.fromJS(name)

		return @

	merge: (name, val) ->
		if _.isString(name)
			@_properties = @_properties.mergeDeep val
		if _.isObject(name)
			@_properties = @_properties.mergeDeep name

		return @

	unset: (name) ->
		invariant _.isString(name), "Store.unset(...): first parameter must be a string."
		delete @_properties = @_properties.remove name if @_properties[name]?
		return @

	getCurrentActionID: () ->
		invariant @_currentActionInstance?, """
			Action id is only available inside an action handler, in the current event loop iteration.
			If you need to, you can call this function before you do any asynchronous work.
		"""
		@_currentActionInstance.actionID


	###
	# Method for calling handlers on the store when an action is executed.
	#
	# @param {string} actionName The name of the executed action
	# @param {mixed} payload The payload passed to the handler
	# @param {array} waitFor An array of other signals to wait for in this dispatcher run.
	###
	_handleAction: (actionInstance, waitFor) =>
		return unless @constructor._handlers?[actionInstance.type]?
		# Call the handler with the context of this store instance
		@_currentActionInstance = actionInstance
		@constructor._handlers[actionInstance.type].call @, actionInstance.payload, waitFor
		@_currentActionInstance = null
