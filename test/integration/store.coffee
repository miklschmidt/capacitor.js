Store            = require '../../src/store'
EntityStore      = require '../../src/entity-store'
ListStore        = require '../../src/list-store'
IndexedListStore = require '../../src/indexed-list-store'
SetStore         = require '../../src/set-store'
IndexedSetStore  = require '../../src/indexed-set-store'
invariant        = require '../../src/invariant'
InvariantError   = require '../../src/invariant-error'
ActionCreator    = require '../../src/action-creator'
actionManager    = require '../../src/action-manager'

{expect}         = require 'chai'
Immutable        = require 'immutable'
sinon            = require 'sinon'


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

	it 'should throw when trying to define a one to one relationship without an EntityStore', () ->
		profile = new class ProfileStore extends Store

		user = new class UserStore extends EntityStore

			expect () => @hasOne 'profile', profile
			.to.throw InvariantError

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

	it 'should throw when trying to define a one to many relationship without a ListStore', () ->
		article = new class ArticleStore extends EntityStore

		usersArticles = new class ArticleListStore extends IndexedListStore
			containsEntity: article

		user = new class UserStore extends Store

			expect () => @hasMany('articles', usersArticles)
			.to.throw InvariantError

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

	it 'should change when relation changes', () ->

		action = actionManager.create 'store-relationship-change-test-action'

		entity = new class TestEntityStore extends EntityStore

			@action action, () ->
				# Just to make sure the batch process works.
				@changed()
				@changed()
				@changed()
				@changed()

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

			getInterface: () ->
				obj = super
				obj.dispatch = @changed.dispatch
				obj

		list = new class TestListStore extends ListStore

			@action action, () ->
				# Just to make sure the batch process works.
				@changed()
				@changed()
				@changed()
				@changed()

			containsEntity: entity
			initialize: () ->
				super
				@add 1

			getInterface: () ->
				obj = super
				obj.dispatch = @changed.dispatch
				obj

		store = new class TestStore extends Store

			@hasOne 'testEntity', entity
			@hasMany 'testEntities', list

		changed = sinon.spy()
		store.changed.add changed

		list.dispatch()
		entity.dispatch()

		# When entity changes, list changes again so we expect 3 change events, not 2
		expect changed.callCount
		.to.equal 3

		changedViaAction = sinon.spy()

		store.changed.add changedViaAction

		creator = new class TestActionCreator extends ActionCreator
		creator.dispatch action

		# Batched change events so only 1 change event should be dispatched.
		# Even though both the profile and the usersArticles are changed.
		expect changedViaAction.callCount
		.to.equal 1

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


	it 'should return the same immutable for a dereferenced item if the item did not change', () ->

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
			@hasOne 'testEntity', entity

			initialize: () ->
				super
				@set id: 1, testEntity: 1

		first = store.get()
		second = store.get()

		expect first
		.to.equal second

	it 'should not try to dereference nonexistant items', () ->

		entity2 = new class TestEntity2Store extends EntityStore

		list = new class TestListStore extends IndexedListStore
			containsEntity: entity2
			initialize: () ->
				super
				@add 1, 1

		entity = new class TestEntityStore extends EntityStore
			@hasMany('testEntities').through(list)

		store = new class TestStore extends Store

			@hasOne 'testEntity', entity

			initialize: () ->
				super
				@set id: 1, testEntity: 1

		expect store.get('testEntity')
		.to.not.exist

	it 'should not dereference when using Raw methods', () ->

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
			@hasOne 'testEntity', entity

			dereference: sinon.spy()

			initialize: () ->
				super
				@set id: 1, testEntity: 1

				expect @getRaw('testEntity')
				.to.equal 1

				expect @getRaw('testEntities')

				expect @getRawIn(['testEntity', 'value'])

				expect @getRawIn(['testEntities', 0, 'value'])

				expect @dereference.called
				.to.equal false

	it 'should be able to unset a value', () ->

		entity = new class TestEntityStore extends EntityStore

			initialize: () ->
				super
				@setItem id: 1, value: 'whatever'

		store = new class TestStore extends Store

			@hasOne 'test', entity

			initialize: () ->
				super
				@set 'test', 1
				@set 'another', 'test'

				expect @get('test').get('value')
				.to.equal 'whatever'

				expect @get('another')
				.to.equal 'test'

				@unset 'test'
				@unset 'another'

				expect @get('test')
				.to.not.exist

				expect @get('test')
				.to.not.exist


	it 'should be able to define a one to many relationship with a ListStore', () ->
		article = new class ArticleStore extends EntityStore

		randomArticles = new class ArticleListStore extends ListStore
			containsEntity: article

		user = new class UserStore extends EntityStore

			expect () => @hasMany('articles', randomArticles)
			.to.not.throw Error


	it 'should be able to define a one to many relationship with a SetStore', () ->
		article = new class ArticleStore extends EntityStore

		randomArticles = new class ArticleListStore extends SetStore
			containsEntity: article

		user = new class UserStore extends EntityStore

			expect () => @hasMany('articles', randomArticles)
			.to.not.throw Error
