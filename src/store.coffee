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

module.exports = class Store

	###
	# @static
	# @private
	###
	@_handlers: null

	###
	# @static
	# @private
	###
	@_references: null

	###
	# @private
	###
	_properties: null

	###
	# @private
	###
	_cache: null

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
			#{@constructor.name}.action(...): Provided action should be created via the action 
			manager and a handler must be given as a second parameter.
			If you're trying to reference a prototype method, don't do that.
			"""
		invariant !@_handlers[action]?,
			"#{@constructor.name}.action(...): You can only define one handler pr action"

		@_handlers[action] = fn

		# Check if the function is a reference to a prototype method, and warn.
		for own prop of (@::) when fn is @::[prop]
			console.warn """
				#{@constructor.name}.action(...): Action %s is referring to a method on the store prototype (%O).
				This is bad practice and should be avoided.
				The handler itself may call prototype methods,
				and is called with the store instance as context for that reason.
				""", action, @
		return null

	###
	# Static method for defining a one to one relationship to another store.
	#
	# @static
	# @param {String} key The key that should reference another store
	# @param {EntityStore} entityStore the entity store that is referenced from this store
	###
	@hasOne: (key, entityStore) ->
		invariant entityStore?.getItem, """
			#{@constructor.name}.entityReference(...): the entity store specified for the key #{key} is invalid. 
			You must specify a store with a 'getItem' method.
		"""
		@_references ?= {}
		@_references[key] = {store: entityStore, type: 'entity'}
		return null

	###
	# Static method for defining a one to many relationship to another store.
	#
	# @static
	# @param {String} key The key that should reference another store
	# @param {ListStore} listStore the list store that is referenced from this store
	###
	@hasMany: (key, listStore) ->
		invariant listStore?.getItems, """
			#{@constructor.name}.listReference(...): the list store specified for the key #{key} is invalid. 
			You must specify a list store with a 'getItems' method.
		"""
		@_references ?= {}
		@_references[key] = {store: listStore, type: 'list'}
		return null

	###
	# Constructor function that sets up actions and events on the store
	###
	constructor: () ->
		dispatcher.register(@)
		@_properties = Immutable.Map()
		@_cache = Immutable.Map()

		# Set up change event.
		@changed = new Signal

		# Call initialize, if it's there.
		@initialize()

		# Return proxy object used to interact with this store
		return @getInterface()

	initialize: () ->

	###
	# Override this to change which methods are available to consumers.
	# NOTE: Remember that nothing but the store itself should be able to change the data in the store.
	###
	getInterface: () ->
		return {
			get: @get.bind(@)
			getIn: @getIn.bind(@)
			@changed
			_id: @_id
		}

	###
	# Method for caching results, this is used when dereferencing to make sure the same immutable is
	# returned if the references haven't changed.
	#
	# @param {String} name The name for the cache
	# @param {value} name The value that is written to the cache if it's different from the previous value.
	###
	cache: (name, value) ->
		last = @_cache.get name

		if !Immutable.Iterable.isIterable(last) or !Immutable.is(last, item)
			@_cache = @_cache.set name, item
			return item

		return last

	###
	# Method for dereferencing a value by using the key's related store.
	#
	# @param {String} key The key for the value to dereference
	###
	dereference: (key) ->
		reference = @constructor._references?[key]
		invariant reference?.store?, """#{@constructor.name}.dereference(...): There's no reference store for the key #{key}"""

		if reference.type is 'entity'
			id = @_properties.get key
			invariant _.isString(id) or _.isNumber(id), """#{@constructor.name}.dereference(...): The value for #{key} was neither a string nor a number.
				The value of #{key} should be the id of the item that {key} is a reference to.
			"""
			result = reference.store.getItem id

		else if reference.type is 'list'
			result = reference.store.getItems()

		return result

	getIn: (path) ->
		result = @get()
		result = result.get(key) for key in path when result?
		return result

	get: (key) ->
		val = null
		if key?
			invariant _.isString(key), "#{@constructor.name}.get(...): first parameter should be undefined or a string"
			if @constructor._references?[key]?
				val = @dereference key
			else
				val = @_properties.get key
		else
			# Handle dereferencing
			references = @constructor._references
			if references?
				dereferencedProperties = @_properties.withMutations (map) -> 
					for key of references
						map.set key, @dereference(key)
				val = @cache 'dereffed_props', dereferencedProperties
			else
				# No references defined, just return the props.
				val = @_properties
		return val

	validateReferenceOnSet: (type, key, value) ->
		switch type
			when 'entity'
				invariant _.isString(values[key]) or _.isNumber(values[key]), """
					#{@constructor.name}.set(...): #{key} must be an id for an entity on #{references[key].store.constructor.name}.
					Ie. either a string or a number.
				"""
				return value
			when 'list'
				# One should never set a value for a list reference, warn.
				console.warn """
					#{@constructor.name}.set(...): #{key} is a reference to the list store #{references[key].store.constructor.name}.
					You can't set a value for a reference to a list store. Defaulting to null.
				"""
				return null

	set: (key, val) ->
		invariant _.isObject(key) or _.isString(key) and val?,
			"""
				#{@constructor.name}.set(...): You can only set an object or pass a string and a value.
				Use #{@constructor.name}.unset(#{key}) to unset the property.
			"""

		if _.isString(key)
			obj = {}
			obj[key] = Immutable.fromJS(val)
			@_properties = @_properties.merge Immutable.Map obj

		if _.isObject(key)
			keys = key
			values = {}
			references = @constructor._references
			for key of keys 
				if key in _.keys(references)
					values[key] = @validateReferenceOnSet type, key, keys[key]
				else
					values[key] = keys[key]

			@_properties = @_properties.merge Immutable.fromJS values

		return @

	merge: (name, val) ->
		if _.isString(name)
			@_properties = @_properties.mergeDeep val
		if _.isObject(name)
			@_properties = @_properties.mergeDeep name

		return @

	unset: (name) ->
		invariant _.isString(name), "#{@constructor.name}.unset(...): first parameter must be a string."
		delete @_properties = @_properties.remove name if @_properties[name]?
		return @

	getCurrentActionID: () ->
		invariant @_currentActionInstance?, """
			Action id is only available inside an action handler, in the current event loop iteration.
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
