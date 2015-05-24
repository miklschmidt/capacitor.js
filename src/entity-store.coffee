Store = require 'store'
invariant = require 'invariant'
Immutable = require 'immutable'
_ = require 'lodash'

module.exports = class ContentStore extends Store

	@hasMany: (key, listStore) ->
		if arguments.length is 1
			return through: (indexedListStore) ->
				invariant indexedListStore?.getItems, """
					#{@constructor.name}.hasMany(...).through(...): the indexed list store specified for the key #{key} is invalid.
					You must specify an indexed list store with a 'getItems' method
				"""
				@_references ?= {}
				@_references[key] = {store: indexedListStore, type: 'indexed-list'}
				return null

		super

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

		if reference.type is 'entity'
			id = item.get key
			invariant _.isString(id) or _.isNumber(id), """
				#{@constructor.name}.dereference(...): The value for #{key} was neither a string nor a number.
				The value of #{key} should be the id of the item that {key} is a reference to.
			"""
			result = reference.store.getItem id

		else if reference.type is 'list'
			result = reference.store.getItems()

		else if reference.type is 'indexed-list'
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
			dereferencedProperties = item.withMutations (map) -> 
				for key of references
					map.set key, @dereference(item, key)
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
			ContentStore.addItem(...): Can't add an item with no id (item.id is missing).
		"""
		@setItems @get('items').set(item.get('id'), item)

	setItems: (items) ->
		@set 'items', items

	getItem: (id) ->
		@derefenceItem @get('items').get(id)

	getItems: () ->
		@get('items').map (item) => @dereferenceItem item
		

	###
	# Method for getting values from this store, with dereferencing disabled.
	# References for an entity store is defined for the items not for the store itself.
	#
	# @overrides Store::get 
	###
	get: () ->
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

	removeItem: (id) ->
		items = @get 'items'
		@set 'items', items.remove(id)