IndexedCollectionStore = require './indexed-collection-store'
Immutable              = require 'immutable'

module.exports = class IndexedListStore extends IndexedCollectionStore

	_fromJS: Immutable.List

	_remove: (ids, id) ->
		# Remove the first occurrence of id
		return ids.remove ids.indexOf id
