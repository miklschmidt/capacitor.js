Store     = require 'store'
invariant = require 'invariant'
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

	# Defines which entities the list contains
	entityStore: null

	getInterface: () ->
		interfaceObj = super
		interfaceObj.getItems = @getItems.bind @
		interfaceObj.getItem = @getItem.bind @
		return interfaceObj

	initialize: () ->
		invariant @entityStore?, """
			ListStore.initialize(...): You need to define a content store to use the list store
		"""
		@set 'ids', Immutable.List()
		# This store has effictively changed if it's content store has changed.
		@entityStore.changed.add () => @changed.dispatch()

	add: (ids) ->
		if Immutable.Iterable.isIterable(ids)
			ids = ids.toJS()
		invariant _.isNumber(ids) or _.isString(ids) or _.isArray(ids), """
			ListStore.add(...): Add only accepts an id or an array of ids.
		"""

		ids = [ids] unless _.isArray(ids)

		currentIds = @get 'ids'
		for id in ids when not currentIds.includes(id)
			currentIds = currentIds.push id
		@set 'ids', currentIds

	remove: (id) ->
		currentIds = @get 'ids'
		index = currentIds.indexOf id
		invariant currentIds.indexOf isnt -1, """
			ListStore.remove(...): Id #{id} was not found in the store
		"""
		currentIds = currentIds.remove(indexOf)
		@set 'ids', currentIds

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
		@set 'ids', Immutable.List(ids)

	getItems: () ->
		ids = @get 'ids'
		items = @entityStore.getItemsWithIds ids
		return @cache 'ids_items', items

	getItem: (id) ->
		return @entityStore.getItem id if @get('ids').includes id
		return null