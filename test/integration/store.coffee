Store = require '../../src/store'
EntityStore = require '../../src/entity-store'
ListStore = require '../../src/list-store'

invariant = require '../../src/invariant'
{expect} = require 'chai'
Immutable = require 'immutable'

describe 'Store', () ->

	it 'should be able to define a one to one relationship', () ->

		entity = new class TestEntityStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

		store = new class TestStore extends Store

			@hasOne 'testEntity', entity

		expect TestStore._references?.testEntity
		.to.exist

		expect TestStore._references.testEntity.type
		.to.equal 'entity'

		expect TestStore._references.testEntity.store
		.to.be.equal entity

	it 'should be able to define a one to many relationship', () ->

		entity = new class TestEntityStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

		list = new class TestListStore extends ListStore

			containsEntity: entity
			initialize: () ->
				super
				@add 1

		store = new class TestStore extends Store

			@hasMany 'testEntities', list

		expect TestStore._references?.testEntities
		.to.exist

		expect TestStore._references.testEntities.type
		.to.equal 'list'

		expect TestStore._references.testEntities.store
		.to.be.equal list

	it 'should be able to define several relationships', () ->

		entity = new class TestEntityStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

		list = new class TestListStore extends ListStore

			containsEntity: entity
			initialize: () ->
				super
				@add 1

		store = new class TestStore extends Store

			@hasOne 'testEntity', entity
			@hasOne 'testEntity2', entity
			@hasMany 'testEntities', list
			@hasMany 'testEntities2', list

		expect TestStore._references?.testEntity
		.to.exist

		expect TestStore._references.testEntity.type
		.to.equal 'entity'

		expect TestStore._references.testEntity.store
		.to.be.equal entity

		expect TestStore._references?.testEntity2
		.to.exist

		expect TestStore._references.testEntity2.type
		.to.equal 'entity'

		expect TestStore._references.testEntity2.store
		.to.be.equal entity

		expect TestStore._references?.testEntities
		.to.exist

		expect TestStore._references.testEntities.type
		.to.equal 'list'

		expect TestStore._references.testEntities.store
		.to.be.equal list

		expect TestStore._references?.testEntities2
		.to.exist

		expect TestStore._references.testEntities2.type
		.to.equal 'list'

		expect TestStore._references.testEntities2.store
		.to.be.equal list

	it 'should return null when the property value for a one to one relationship is undefined', () ->
		entity = new class TestEntityStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

		store = new class TestStore extends Store

			@hasOne 'testEntity', entity

		expect store.get 'testEntity'
		.to.be.null


	it 'should be able to dereference a one to one relationship', () ->

		entity = new class TestEntityStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

		store = new class TestStore extends Store

			@hasOne 'testEntity', entity

			initialize: () ->
				super
				@set 'testEntity', 1

		expect store.get 'testEntity'
		.to.be.equal entity.getItem(1)

	it 'should be able to dereference a one to many relationship', () ->

		entity = new class TestEntityStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

		list = new class TestListStore extends ListStore

			containsEntity: entity
			initialize: () ->
				super
				@add 1

		store = new class TestStore extends Store

			@hasMany 'testEntities', list

		expect Immutable.List.isList store.get 'testEntities'
		.to.be.true

		expect store.get('testEntities').get(0) # First entry in the list
		.to.be.equal entity.getItem(1)




