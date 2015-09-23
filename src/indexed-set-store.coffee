IndexedCollectionStore = require './indexed-collection-store'
Immutable              = require 'immutable'

module.exports = class IndexedSetStore extends IndexedCollectionStore

	@_getStoreType: () ->
		return 'indexed-set'

	_fromJS: Immutable.Set

	_remove: (ids, id) ->
		return ids.delete id
