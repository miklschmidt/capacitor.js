CollectionStore = require './collection-store'
Immutable       = require 'immutable'

module.exports = class SetStore extends CollectionStore

	@_getStoreType: () ->
		return 'set'

	_fromJS: Immutable.Set

	_remove: (ids, id) ->
		return ids.delete id
