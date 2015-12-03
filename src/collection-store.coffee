Store     = require './store'
invariant = require './invariant'
Immutable = require 'immutable'
_         = require 'lodash'

###
# Abstract store containing a collection of ids referencing other entities
###

module.exports = class CollectionStore extends Store

	# You can't define relationships on a collection store.
	@hasOne: () ->
		type = @constructor._getStoreType()
		throw new Error """
			#{@constructor.name}.hasOne(...): You can't define relationships on a #{type} store
		"""
	@hasMany: () ->
		type = @constructor._getStoreType()
		throw new Error """
			#{@constructor.name}.hasMany(...): You can't define relationships on a #{type} store
		"""

	@_getStoreType: () -> 'collection'

	# Convert the array `values` to an Immutable.Collection type
	_fromJS: (values) ->
		throw new Error """
			#{@constructor.name}._fromJS(...): This method is abstract
		"""

	# Remove `id` from `ids` (in which it's assured to be present)
	_remove: (ids, id) ->
		throw new Error """
			#{@constructor.name}._remove(...): This method is abstract
		"""

	# Defines which entities the collection contains
	containsEntity: null

	getInterface: () ->
		interfaceObj = super
		interfaceObj.getItems = @getItems.bind @
		interfaceObj.getItem = @getItem.bind @
		return interfaceObj

	initialize: () ->
		super
		invariant @containsEntity?, """
			#{@constructor.name}.initialize(...): Missing @containsEntity property.
			You need to define an entity store to use the #{@constructor._getStoreType()} store.
		"""
		@setIds @_fromJS([])
		# This store has effictively changed if it's entity store has changed.
		@containsEntity.changed.addImmediate () => @changed.dispatch()

		unless @constructor._getStoreType() is 'collection'
			console.error "#{@constructor.name}.initialize(): Overriding _getStoreType() is deprecated and is no longer necessary."

	add: (ids) ->
		if Immutable.Iterable.isIterable(ids)
			ids = ids.toJS()
		invariant _.isNumber(ids) or _.isString(ids) or _.isArray(ids), """
			#{@constructor.name}.add(...): Add only accepts an id or an array of ids.
		"""

		ids = [ids] unless _.isArray(ids)

		currentIds = @getIds()
		newIds = currentIds.concat ids
		@setIds newIds

	remove: (id) ->
		currentIds = @getIds()
		invariant currentIds.contains id, """
			#{@constructor.name}.remove(...): Id #{id} was not found in the store
		"""
		newIds = @_remove currentIds, id
		@setIds newIds

	reset: (ids) ->
		if Immutable.Iterable.isIterable(ids)
			ids = ids.toJS()
		invariant not ids? or _.isNumber(ids) or _.isString(ids) or _.isArray(ids), """
			#{@constructor.name}.reset(...): Reset only accepts an id, an array of ids or nothing.
		"""
		if ids?
			ids = [ids] unless _.isArray(ids)
		else
			ids = []
		@setIds @_fromJS(ids)

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
