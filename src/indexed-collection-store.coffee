Store     = require './store'
invariant = require './invariant'
Immutable = require 'immutable'
_         = require 'lodash'

###
# Abstract store containing a map from ids to collections of ids referencing other entities
###

module.exports = class IndexedCollectionStore extends Store

	# You can't define relationships on an indexed collection store.
	@hasOne: () ->
		type = type = @constructor._getStoreType().replace('-', ' ')
		throw new Error """
			#{@constructor.name}.hasOne(...): You can't define relationships on a #{type} store
		"""
	@hasMany: () ->
		type = type = @constructor._getStoreType().replace('-', ' ')
		throw new Error """
			#{@constructor.name}.hasMany(...): You can't define relationships on a #{type} store
		"""

	@_getStoreType: () -> 'indexed-collection'

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

	# Defines which entities the collection contain
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
			You need to define an entity store to use the #{@constructor.name}.
		"""
		@set 'map', Immutable.Map {}
		# This store has effictively changed if it's entity store has changed.
		@containsEntity.changed.addImmediate (() -> @changed.dispatch()), @

		unless @constructor._getStoreType() is 'indexed-collection'
			console.error "#{@constructor.name}.initialize(): Overriding _getStoreType() is deprecated and is no longer necessary."

	add: (index, ids) ->
		invariant _.isNumber(index) or _.isString(index), """
			#{@constructor.name}.add(...): First parameter should be a number (id) or a string identifier.
		"""

		invariant _.isNumber(ids) or _.isString(ids) or _.isArray(ids), """
			#{@constructor.name}.add(...): Second parameter should be a number/string (id) or an array of numbers/strings (ids).
		"""

		ids = [ids] unless _.isArray(ids)

		currentIds = @getIds(index)
		existingType = if ids.size > 0 then typeof(ids[0]) else null
		if currentIds.size > 0
			existingType = typeof currentIds.first()
		else if ids.length > 0
			existingType = typeof(ids[0])

		for id in ids
			invariant existingType is typeof(id), """
				#{@constructor.name}.add(...): Trying to mix numbers and strings as ids
			"""

		@setIds index, currentIds.concat(ids)

	getIds: (index) ->
		@get('map').get(index) ? @_fromJS([])

	setIds: (index, ids) ->
		ids = Immutable.fromJS(ids)
		map = @get 'map'
		if ids.size > 0
			t = typeof(ids.first())
			invariant t is 'number' or t is 'string', """
				#{@constructor.name}.setIds(...) type of ids must be a number or a string
			"""
			invariant !ids.find((e) -> typeof(e) != t)?, """
				#{@constructor.name}.setIds(...) mixed numbers and strings in ids
			"""
		map = map.set index, ids
		@set 'map', map

	remove: (index, id) ->
		currentIds = @getIds index
		invariant currentIds.contains id, """
			#{@constructor.name}.remove(...): Id #{id} was not found in the store
		"""
		newIds = @_remove currentIds, id
		@setIds index, newIds

	removeIndex: (index) ->
		map = @get('map')
		map = map.remove index
		@set 'map', map
		@unset 'cached_index_'+index

	resetAll: () ->
		@set 'map', Immutable.Map({})

	reset: (index, ids) ->
		invariant index?, """
			#{@constructor.name}.reset(...): No index was provided.
		"""
		invariant not ids? or (_.isNumber(ids) or _.isString(ids) or _.isArray(ids)), """
			#{@constructor.name}.reset(...): Reset only accepts an id, an array of ids or nothing as the second parameter.
		"""
		if ids?
			ids = [ids] unless _.isArray(ids)
		else
			ids = []
		@setIds index, ids

	getItems: (index) ->
		ids = @getIds(index)
		items = @containsEntity.getItemsWithIds ids

		return @cache('cached_index_' + index, items)

	getItem: (index, id) ->
		ids = @getIds(index)
		return @containsEntity.getItem(id) if ids.includes id
		return null
