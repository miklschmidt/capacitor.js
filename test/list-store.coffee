EntityStore = require '../src/entity-store'
ListStore = require '../src/list-store'
InvariantError = require '../src/invariant-error'

expect = require('chai').expect
sinon = require 'sinon'
Immutable = require 'immutable'

describe 'ListStore', () ->

	it 'should return the correct interface', () ->

		instance = new class TestEntityStore extends EntityStore

		testInstance = new class TestListStore extends ListStore
			containsEntity: instance

		expect testInstance.getItems
		.to.be.a 'function'

		expect testInstance.getItem
		.to.be.a 'function'

	it 'should not allow relationships', () ->

		expect () ->
			new class TestListStore extends ListStore
				@hasOne()
		.to.throw Error

		expect () ->
			new class TestListStore extends ListStore
				@hasMany()
		.to.throw Error

	it 'should throw when containsEntity is not defined', () ->

		expect () ->
			instance = new class TestListStore extends ListStore
		.to.throw InvariantError


	it 'should initialize properly when containsEntity is defined', () ->

		instance = new class TestEntityStore extends EntityStore

		expect () ->
			new class TestListStore extends ListStore
				containsEntity: instance
		.to.not.throw InvariantError

	it 'should properly propagate change events from the entity store', () ->

		entityInstance = new class TestEntityStore extends EntityStore
			getInterface: () ->
				obj = super
				obj.dispatch = @changed.dispatch
				obj

		changed = sinon.spy()

		instance = new class TestListStore extends ListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@changed.add changed

		entityInstance.dispatch()

		expect changed.calledOnce
		.to.be.true

	it 'should be able to add and get ids for a given index', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestListStore extends ListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add [1, 2, 3]

				expect Immutable.List.isList @getIds()
				.to.be.true

				expect @getIds().count()
				.to.equal 3

				@add 4	# Add another id

				expect @getIds().count()
				.to.equal 4

	it 'should be able to remove an id', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestListStore extends ListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add [1, 2, 3]

				@remove 2

				expect @getIds().count()
				.to.equal 2

				expect @getIds().get(0)
				.to.equal 1

				expect @getIds().get(1)
				.to.equal 3

	it 'should be able to reset the list', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestListStore extends ListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add [1, 2, 3]

				expect @getIds().count()
				.to.equal 3

				@reset()

				expect @getIds().count()
				.to.equal 0

				@reset [1, 2, 3]

				expect @getIds().count()
				.to.equal 3

	it 'should throw when reset was called incorrectly', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestListStore extends ListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add [1, 2, 3]

				expect @getIds().count()
				.to.equal 3

				expect () =>
					@reset({})
				.to.throw InvariantError

	it 'should be able to get and dereference items contained in a list', () ->

		entityInstance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem {id: 1, test: "value"}
				@setItem {id: 2, test: "another value"}

		instance = new class TestListStore extends ListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add [1, 2]

				items = @getItems()
				
				expect items.count()
				.to.equal 2

				expect items.get(0).get('test')
				.to.equal "value"

				expect items.get(1).get('test')
				.to.equal "another value"

				item = @getItem(1)
				expect item.get('test')
				.to.equal "value"

	it 'should return the same immutable when the list did not change', () ->

		entityInstance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem {id: 1, test: "value"}
				@setItem {id: 2, test: "another value"}

		instance = new class TestListStore extends ListStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add [1, 2]

				first = @getItems()
				second = @getItems()	

				@remove 1

				third = @getItems()

				expect first
				.to.equal second

				expect third
				.to.not.equal first


