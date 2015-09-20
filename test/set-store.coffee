EntityStore = require '../src/entity-store'
SetStore = require '../src/set-store'
InvariantError = require '../src/invariant-error'

expect = require('chai').expect
sinon = require 'sinon'
Immutable = require 'immutable'

describe 'SetStore', () ->

	it 'should contain unique values', () ->

		instance = new class TestEntityStore extends EntityStore

		testInstance = new class TestSetStore extends SetStore
			containsEntity: instance

			initialize: () ->
				super
				@add [1,2,3]

				expect @getIds().count()
				.to.equal 3

				@add 2

				expect @getIds().count()
				.to.equal 3

				@remove 2

				expect @getIds().count()
				.to.equal 2

	it 'should return the same immutable when id is already contained', () ->

		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem {id: 1, test: "value"}
				@setItem {id: 2, test: "another value"}
				@setItem {id: 3, test: "third value"}

		testInstance = new class TestSetStore extends SetStore
			containsEntity: instance

			initialize: () ->
				super
				@add [1,2]

				initial = @getItems()

				@add 1

				duplicate = @getItems()

				@add 3

				changed = @getItems()

				expect initial
				.to.equal duplicate

				expect initial
				.to.not.equal changed

	it 'should return the correct interface', () ->

		instance = new class TestEntityStore extends EntityStore

		testInstance = new class TestSetStore extends SetStore
			containsEntity: instance

		expect testInstance.getItems
		.to.be.a 'function'

		expect testInstance.getItem
		.to.be.a 'function'

	it 'should not allow relationships', () ->

		expect () ->
			new class TestSetStore extends SetStore
				@hasOne()
		.to.throw Error

		expect () ->
			new class TestSetStore extends SetStore
				@hasMany()
		.to.throw Error

	it 'should throw when containsEntity is not defined', () ->

		expect () ->
			instance = new class TestSetStore extends SetStore
		.to.throw InvariantError


	it 'should initialize properly when containsEntity is defined', () ->

		instance = new class TestEntityStore extends EntityStore

		expect () ->
			new class TestSetStore extends SetStore
				containsEntity: instance
		.to.not.throw InvariantError

	it 'should properly propagate change events from the entity store', () ->

		entityInstance = new class TestEntityStore extends EntityStore
			getInterface: () ->
				obj = super
				obj.dispatch = @changed.dispatch
				obj

		changed = sinon.spy()

		instance = new class TestSetStore extends SetStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@changed.add changed

		entityInstance.dispatch()

		expect changed.calledOnce
		.to.be.true

	it 'should be able to add and get ids for a given index', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestSetStore extends SetStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add [1, 2, 3]

				expect Immutable.Set.isSet @getIds()
				.to.be.true

				expect @getIds().count()
				.to.equal 3

				@add 4	# Add another id

				expect @getIds().count()
				.to.equal 4

	it 'should be able to remove an id', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestSetStore extends SetStore
			containsEntity: entityInstance

			initialize: () ->
				super
				@add [1, 2, 3]

				@remove 2

				expect @getIds().count()
				.to.equal 2

				expect @getIds().equals(Immutable.Set([1,3]))
				.to.be.true

	it 'should be able to reset the list', () ->

		entityInstance = new class TestEntityStore extends EntityStore

		instance = new class TestSetStore extends SetStore
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

		instance = new class TestSetStore extends SetStore
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

		instance = new class TestSetStore extends SetStore
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

		instance = new class TestSetStore extends SetStore
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

