EntityStore          = require('../src/entity-store')
Action         = require('../src/action')
ActionCreator  = require('../src/action-creator')
InvariantError = require('../src/invariant-error')
_              = require('lodash')
{expect}       = require 'chai'
sinon          = require 'sinon'
Immutable      = require 'immutable'

describe 'EntityStore', () ->

	it 'should be able to get and set properties like a regular store', () ->
		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@set 'test', 'test'

		expect instance.get 'test'
		.to.equal 'test'

	it 'be able to set and get an item', () ->

		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem id: 1, test: 'value'

		expect instance.getItem(1).get 'test'
		.to.equal 'value'

	it 'should be able to get all items as a list', () ->

		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem id: 1, test: 'value'
				@setItem id: 2, test: 'value2'
				@setItem id: 3, test: 'value3'

		items = instance.getItems()
		expect items
		.to.exist

		expect Immutable.Iterable.isIterable items
		.to.be.true

		expect items.count()
		.to.equal 3

	it 'should throw if setting an item without an id', () ->
		expect () ->
			instance = new class TestEntityStore extends EntityStore
				initialize: () ->
					super
					@setItem test: 'value'
		.to.throw InvariantError

	it 'should throw if setItems is called without a map', () ->
		expect () ->
			instance = new class TestEntityStore extends EntityStore
				initialize: () ->
					super
					@setItems {}
		.to.throw InvariantError

	it 'should return a list of items corresponding to given ids in the correct order', () ->
		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem id: 1, test: 'value'
				@setItem id: 2, test: 'value2'
				@setItem id: 3, test: 'value3'

		list1 = instance.getItemsWithIds([1, 2])
		list2 = instance.getItemsWithIds([3, 2])

		expect Immutable.List.isList(list1)
		.to.be.true

		expect Immutable.List.isList(list2)
		.to.be.true

		expect list1.count()
		.to.equal 2

		expect list2.count()
		.to.equal 2

		expect list1.toJS()[0].id
		.to.equal 1 

		expect list1.toJS()[1].id
		.to.equal 2

		expect list2.toJS()[0].id
		.to.equal 3

		expect list2.toJS()[1].id
		.to.equal 2


	it 'should return the same item instance when nothing changed', () ->

		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem id: 1, test: 'value'

		expect instance.getItem(1)
		.to.be.equal instance.getItem(1)

	it 'should return a new item instance when the item has changed', () ->

		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem id: 1, test: 'value'

			getInterface: () ->
				obj = super
				obj.setItem = @setItem.bind(@)
				obj

		first = instance.getItem(1)
		instance.setItem id:1, test: 'value2'
		second = instance.getItem(1)

		expect first
		.to.not.be.equal second

	it 'should return the same map when nothing changed', () ->

		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem id: 1, test: 'value'
				@setItem id: 2, test: 'value2'
				@setItem id: 3, test: 'value3'

		expect instance.getItems()
		.to.be.equal instance.getItems()

	it 'should return another map when an item changed', () ->

		instance = new class TestEntityStore extends EntityStore
			initialize: () ->
				super
				@setItem id: 1, test: 'value'
				@setItem id: 2, test: 'value2'
				@setItem id: 3, test: 'value3'

			getInterface: () ->
				obj = super
				obj.setItem = @setItem.bind(@)
				obj

		first = instance.getItems()
		instance.setItem id: 2, test: 'waaaat'
		second = instance.getItems()

		expect first
		.to.not.be.equal second







