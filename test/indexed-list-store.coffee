EntityStore = require '../src/entity-store'
IndexedListStore = require '../src/indexed-list-store'
InvariantError = require '../src/invariant-error'

expect = require('chai').expect
sinon = require 'sinon'
Immutable = require 'immutable'

describe 'IndexedListStore', () ->

	it 'should return the correct interface', () ->

		instance = new class TestEntityStore extends EntityStore

		testInstance = new class TestIndexListStore extends IndexedListStore
			containsEntity: instance

		expect testInstance.getItems
		.to.be.a 'function'

		expect testInstance.getItem
		.to.be.a 'function'

	it 'should not allow relationships', () ->

		expect () ->
			new class TestIndexListStore extends IndexedListStore
				@hasOne()
		.to.throw Error

		expect () ->
			new class TestIndexListStore extends IndexedListStore
				@hasMany()
		.to.throw Error

	it 'should throw when containsEntity is not defined', () ->

		expect () ->
			instance = new class TestIndexListStore extends IndexedListStore
		.to.throw InvariantError


	it 'should initialize properly when containsEntity is defined', () ->

		instance = new class TestEntityStore extends EntityStore

		expect () ->
			new class TestIndexListStore extends IndexedListStore
				containsEntity: instance
		.to.not.throw InvariantError

	it 'should properly propagate change events from the entity store', () ->

		entityInstance = new class TestEntityStore extends EntityStore
			getInterface: () ->
				obj = super
				obj.dispatch = @changed.dispatch
				obj

		changed = sinon.spy()

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@changed.add changed

		entityInstance.dispatch()

		expect changed.calledOnce
		.to.be.true

	it 'should be able to add and get ids for a given index', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add 0, [1, 2, 3]
				@add 1, 1

				expect Immutable.List.isList @getIds(0)
				.to.be.true

				expect @getIds(0).count()
				.to.equal 3

				expect Immutable.List.isList @getIds(1)
				.to.be.true

				expect @getIds(1).count()
				.to.equal 1

	it 'should be able to remove an id', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add 0, [1, 2, 3]

				@remove 0, 2

				expect @getIds(0).count()
				.to.equal 2

				expect @getIds(0).get(0)
				.to.equal 1

				expect @getIds(0).get(1)
				.to.equal 3

	it 'should be able to remove an entire list', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add 0, [1, 2, 3]

				expect @getIds(0).count()
				.to.equal 3

				@removeIndex(0)

				expect @getIds(0).count()
				.to.equal 0

	it 'should be able to reset the entire map', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add 0, [1, 2, 3]
				@add 1, [1, 2, 3]

				expect @getIds(0).count()
				.to.equal 3
				expect @getIds(1).count()
				.to.equal 3

				@resetAll()

				expect @getIds(0).count()
				.to.equal 0

				expect @getIds(1).count()
				.to.equal 0

	it 'should be able to reset an index', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add 0, [1, 2, 3]
				@add 1, [1, 2, 3]

				expect @getIds(0).count()
				.to.equal 3
				expect @getIds(1).count()
				.to.equal 3

				@reset(0)

				expect @getIds(0).count()
				.to.equal 0

				expect @getIds(1).count()
				.to.equal 3

				@reset(1, [1, 2])

				expect @getIds(0).count()
				.to.equal 0

				expect @getIds(1).count()
				.to.equal 2


	it 'should throw when reset was called incorrectly', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add 0, [1, 2, 3]
				@add 1, [1, 2, 3]

				expect @getIds(0).count()
				.to.equal 3
				expect @getIds(1).count()
				.to.equal 3

				expect () =>
					@reset()
				.to.throw InvariantError

				expect () =>
					@reset(1, {})
				.to.throw InvariantError

	it 'should be able to get and dereference items contained in a list', () ->

		entityInstance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem {id: 1, test: "value"}
				@setItem {id: 2, test: "another value"}

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add 0, [1, 2]

				items = @getItems(0)
				
				expect items.count()
				.to.equal 2

				expect items.get(0).get('test')
				.to.equal "value"

				expect items.get(1).get('test')
				.to.equal "another value"

				item = @getItem(0, 1)
				expect item.get('test')
				.to.equal "value"

	it 'should return the same immutable when the list did not change', () ->

		entityInstance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem {id: 1, test: "value"}
				@setItem {id: 2, test: "another value"}

		instance = new class TestIndexListStore extends IndexedListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add 0, [1, 2]

				first = @getItems(0)
				second = @getItems(0)	

				@remove 0, 1

				third = @getItems(0)

				expect first
				.to.equal second

				expect third
				.to.not.equal first


