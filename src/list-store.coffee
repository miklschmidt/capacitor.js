CollectionStore = require './collection-store'
Immutable       = require 'immutable'

module.exports = class ListStore extends CollectionStore

	_fromJS: Immutable.List

	_remove: (ids, id) ->
		# Remove the first occurrence of id
		return ids.remove ids.indexOf id
