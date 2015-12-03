Store = require './store'
invariant = require './invariant'
Immutable = require 'immutable'
_ = require 'lodash'

module.exports = class EntityStore extends Store

	@hasMany: (key, listStore) ->
		if arguments.length is 1
			return through: (relatedStore) =>
				invariant relatedStore._type in ['indexed-list', 'indexed-set'], """
					#{@constructor.name}.hasMany(...).through(...): the related store specified for the key #{key} is invalid.
					You must specify a store that is a descendant of Capacitor.IndexedListStore or Capacitor.IndexedSetStore.
				"""
				@_references ?= {}
				@_references[key] = {store: relatedStore, type: relatedStore._type}
				return null

		super

	@_getStoreType: () ->
		return 'entity'

	###
	# Dereferences a specific key on an item, similar to Store.dereference.
	#
	# @overrides Store::dereference
	# @param {Immutable.Map} item The item that will be dereferenced
	# @param {String} key The key on the item to dereference
	###
	dereference: (item, key) ->
		reference = @constructor._references?[key]
		invariant reference?.store?, """
			#{@constructor.name}.dereference(...): There's no reference store for the key #{key}
		"""

		id = item.get key
		result = null
		if reference.type is 'entity' and id?
			invariant _.isString(id) or _.isNumber(id), """
				#{@constructor.name}.dereference(...): The value for #{key} was neither a string nor a number.
				The value of #{key} should be the id of the item that {key} is a reference to.
			"""
			result = reference.store.getItem id

		else if reference.type in ['list', 'set']
			result = reference.store.getItems()

		else if reference.type in ['indexed-list', 'indexed-set']
			result = reference.store.getItems item.get('id')

		return result

	###
	# Dereferences all defined relationships on an item
	#
	# @param {Immutable.Map} item The item to dereference
	###
	dereferenceItem: (item) ->
		# Handle dereferencing
		references = @constructor._references
		if references?
			that = this
			dereferencedProperties = item.withMutations (map) ->
				for key of references
					map.set key, that.dereference(item, key)
			val = @cache "dereffed-item-#{item.get('id')}", dereferencedProperties
		else
			# No references defined, just return the item.
			val = item

	initialize: () ->
		super
		@set 'items', Immutable.Map()

	getInterface: () ->
		interfaceObj = super
		interfaceObj.getItem = @getItem.bind @
		interfaceObj.getItemsWithIds = @getItemsWithIds.bind @
		interfaceObj.getItems = @getItems.bind @
		return interfaceObj

	setItem: (item) ->
		if !Immutable.Iterable.isIterable(item)
			item = Immutable.fromJS(item)
		invariant item.get('id')?, """
			#{@constructor.name}.addItem(...): Can't add an item with no id (item.id is missing).
		"""
		@setItems @get('items').set(item.get('id'), item)


	setItems: (items) ->
		invariant Immutable.Map.isMap(items), """
			#{@constructor.name}.addItem(...): items has to be an immutable map.
		"""
		@set 'items', items

	getItem: (id) ->
		invariant _.isString(id) or _.isNumber(id), """
			#{@constructor.name}.addItem(...): id has to be either a string or a number.
		"""
		result = null
		item = @get('items').get(id)
		result = @dereferenceItem item if item?
		return result

	getRawItem: (id) ->
		@getRawItems().get(id)

	getItems: () ->
		@cache 'items',  @get('items').map (item) => @dereferenceItem item

	getRawItems: () ->
		@get('items')

	###
	# Method for getting values from this store, with dereferencing disabled.
	# References for an entity store is defined for the items not for the store itself.
	#
	# @overrides Store::get
	###
	get: (key) ->
		val = null
		if key?
			invariant _.isString(key), "#{@constructor.name}.get(...): first parameter should be undefined or a string"
			val = @_properties.get key
		else
			val = @_properties
		return val

	###
	# This method does not guarantee the same list to be returned for the same set of ids.
	# That said, the items contained in the list are gauranteed to be equal to the items in other lists.
	# If you require getting the same List instance on every call, you must cache the results yourself.
	# Use Store::cache for this.
	#
	# @return The items with the given ids, in the same order as specified in ids
	###
	getItemsWithIds: (ids) ->
		if Immutable.Iterable.isIterable(ids)
			ids = ids.toJS()
		result = []
		items = @get 'items'
		for id in ids
			if items.has(id)
				result.push @getItem(id)
		return Immutable.List result

	getRawItemsWithIds: (ids) ->
		if Immutable.Iterable.isIterable(ids)
			ids = ids.toJS()
		result = []
		items = @get 'items'
		for id in ids
			if items.has(id)
				result.push @getRawItem(id)
		return Immutable.List result

	removeItem: (id) ->
		items = @get 'items'
		@set 'items', items.remove(id)
