Store     = require './store'
invariant = require './invariant'
Immutable = require 'immutable'
_         = require 'lodash'

module.exports = class ListStore extends Store

	# You can't define relationships on a list store.
	@hasOne: () ->
		throw new Error """
			#{@constructor.name}.hasOne(...): You can't define relationships on a list store
		"""
	@hasMany: () ->
		throw new Error """
			#{@constructor.name}.hasMany(...): You can't define relationships on a list store
		"""

	@_getStoreType: () ->
		return 'list'

	# Defines which entities the list contains
	containsEntity: null

	getInterface: () ->
		interfaceObj = super
		interfaceObj.getItems = @getItems.bind @
		interfaceObj.getItem = @getItem.bind @
		return interfaceObj

	initialize: () ->
		super
		invariant @containsEntity?, """
			ListStore.initialize(...): Missing @containsEntity property. 
			You need to define an entity store to use the list store.
		"""
		@setIds Immutable.List()
		# This store has effictively changed if it's entity store has changed.
		@containsEntity.changed.addImmediate () => @changed.dispatch()

	add: (ids) ->
		if Immutable.Iterable.isIterable(ids)
			ids = ids.toJS()
		invariant _.isNumber(ids) or _.isString(ids) or _.isArray(ids), """
			ListStore.add(...): Add only accepts an id or an array of ids.
		"""

		ids = [ids] unless _.isArray(ids)

		currentIds = @getIds()
		for id in ids when not currentIds.includes(id)
			currentIds = currentIds.push id
		@setIds currentIds

	remove: (id) ->
		currentIds = @getIds()
		indexOf = currentIds.indexOf id
		invariant indexOf isnt -1, """
			ListStore.remove(...): Id #{id} was not found in the store
		"""
		currentIds = currentIds.remove(indexOf)
		@setIds currentIds

	reset: (ids) ->
		if Immutable.Iterable.isIterable(ids)
			ids = ids.toJS()
		invariant not ids? or _.isNumber(ids) or _.isString(ids) or _.isArray(ids), """
			ListStore.reset(...): Reset only accepts an id, an array of ids or nothing.
		"""
		if ids?
			ids = [ids] unless _.isArray(ids)
		else
			ids = []
		@setIds Immutable.List(ids)

	getIds: () ->
		@get 'ids'

	setIds: (ids) ->
		@set 'ids', ids

	getItems: () ->
		ids = @getIds()
		items = @containsEntity.getItemsWithIds ids
		return @cache 'ids_items', items

	getItem: (id) ->
		return @containsEntity.getItem id if @get('ids').includes id
		return null