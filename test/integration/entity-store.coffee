EntityStore = require '../../src/entity-store'
IndexedListStore = require '../../src/indexed-list-store'
ListStore = require '../../src/list-store'
Store = require '../../src/store'

invariant = require '../../src/invariant'
InvariantError = require '../../src/invariant-error'
{expect} = require 'chai'
Immutable = require 'immutable'
sinon = require 'sinon'

describe 'EntityStore', () ->

	it 'should be able to define a one to one relationship', () ->

		profile = new class ProfileStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, name: 'John Doe'}

		user = new class UserStore extends EntityStore

			@hasOne 'profile', profile

		expect UserStore._references?.profile
		.to.exist

		expect UserStore._references.profile.type
		.to.equal 'entity'

		expect UserStore._references.profile.store
		.to.be.equal profile

	it 'should throw when trying to define a one to one relationship without an EntityStore', () ->
		profile = new class ProfileStore extends Store

		user = new class UserStore extends EntityStore

			expect () => @hasOne 'profile', profile
			.to.throw InvariantError

	it 'should be able to define a many to many relationship through an indexed list store', () ->

		article = new class ArticleStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, title: 'Test Article'}

		usersArticles = new class UserArticleStore extends IndexedListStore

			containsEntity: article
			initialize: () ->
				super
				@add 1, 1

		user = new class UserStore extends EntityStore

			@hasMany('articles').through(usersArticles)

			initialize: () ->
				super
				@setItem {id: 1, email: "johndoe@mail.com"}

		expect UserStore._references?.articles
		.to.exist

		expect UserStore._references.articles.type
		.to.equal 'indexed-list'

		expect UserStore._references.articles.store
		.to.be.equal usersArticles

	it 'should throw when trying to define a many to many relationship without an IndexedListStore', () ->
		article = new class ArticleStore extends EntityStore

		randomArticles = new class ArticleListStore extends ListStore
			containsEntity: article

		user = new class UserStore extends EntityStore

			expect () => @hasMany('articles').through(randomArticles)
			.to.throw InvariantError

	it 'should be able to define several relationships', () ->

		profile = new class ProfileStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

		article = new class ArticleStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, title: 'test article'}

		usersArticles = new class UserArticleStore extends IndexedListStore

			containsEntity: article
			initialize: () ->
				super
				@add 1, 1

		user = new class UserStore extends EntityStore

			@hasOne 'profile', profile
			@hasOne 'profile2', profile
			@hasMany('articles').through(usersArticles)
			@hasMany('articles2').through(usersArticles)

			initialize: () ->
				super
				@setItem {id: 1, name: "John Doe"}


		expect UserStore._references?.profile
		.to.exist

		expect UserStore._references.profile.type
		.to.equal 'entity'

		expect UserStore._references.profile.store
		.to.be.equal profile

		expect UserStore._references?.profile2
		.to.exist

		expect UserStore._references.profile2.type
		.to.equal 'entity'

		expect UserStore._references.profile2.store
		.to.be.equal profile

		expect UserStore._references?.articles
		.to.exist

		expect UserStore._references.articles.type
		.to.equal 'indexed-list'

		expect UserStore._references.articles.store
		.to.be.equal usersArticles

		expect UserStore._references?.articles2
		.to.exist

		expect UserStore._references.articles2.type
		.to.equal 'indexed-list'

		expect UserStore._references.articles2.store
		.to.be.equal usersArticles

	it 'should change when relationships change', () ->

		profile = new class ProfileStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, value: 'test'}

			getInterface: () ->
				obj = super
				obj.dispatch = @changed.dispatch
				obj

		article = new class ArticleStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, title: 'test article'}

		usersArticles = new class UserArticleStore extends IndexedListStore

			containsEntity: article
			initialize: () ->
				super
				@add 1, 1

			getInterface: () ->
				obj = super
				obj.dispatch = @changed.dispatch
				obj

		user = new class UserStore extends EntityStore

			@hasOne 'profile', profile
			@hasMany('articles').through(usersArticles)

			initialize: () ->
				super
				@setItem {id: 1, name: "John Doe"}

		changed = sinon.spy()
		user.changed.add changed

		profile.dispatch()
		usersArticles.dispatch()

		expect changed.callCount
		.to.equal 2

	it 'should return null when the property value for a one to one relationship is undefined', () ->
		profile = new class ProfileStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, name: 'John Doe'}

		user = new class UserStore extends EntityStore

			@hasOne 'profile', profile

			initialize: () ->
				super
				@setItem {id: 1} # No profile

		expect user.getItem(1).get('profile'), 'profile'
		.to.be.null


	it 'should be able to dereference a one to one relationship', () ->

		profile = new class ProfileStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, name: 'John Doe'}

		user = new class UserStore extends EntityStore

			@hasOne 'profile', profile

			initialize: () ->
				super
				@setItem {id: 1, profile: 1}

		expect user.getItem(1).get 'profile'
		.to.be.equal profile.getItem(1)

	it 'should be able to dereference a many to many relationship', () ->

		article = new class ArticleStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, title: 'test article'}

		usersArticles = new class UserArticleStore extends IndexedListStore

			containsEntity: article
			initialize: () ->
				super
				# User with id 1 has article with id 1
				@add 1, 1

		user = new class UserStore extends EntityStore
			@hasMany('articles').through(usersArticles)

			initialize: () ->
				super
				@setItem {id: 1, name: "John Doe"}

		expect Immutable.List.isList user.getItem(1).get('articles')
		.to.be.true

		expect user.getItem(1).get('articles').get(0) # First entry in the list
		.to.be.equal article.getItem(1)

	it 'should return the same immutable for a dereferenced item if the item did not change', () ->
		profile = new class ProfileStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, name: 'John Doe'}

		article = new class ArticleStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, title: 'test article'}

		usersArticles = new class UserArticleStore extends IndexedListStore

			containsEntity: article
			initialize: () ->
				super
				# User with id 1 has article with id 1
				@add 1, 1

		user = new class UserStore extends EntityStore

			@hasOne 'profile', profile
			@hasMany('articles').through(usersArticles)

			initialize: () ->
				super
				@setItem {id: 1, profile: 1, articles: 1}

		first = user.getItem(1)
		second = user.getItem(1)

		expect first
		.to.be.equal second

	it 'should not attempt to dereference items that do not exist', () ->


		article = new class ArticleStore extends EntityStore

		usersArticles = new class UserArticleStore extends IndexedListStore

			containsEntity: article

			initialize: () ->
				super
				@add 1, 1

		profile = new class ProfileStore extends EntityStore
			@hasMany('articles').through(usersArticles)

		user = new class UserStore extends EntityStore

			@hasOne 'profile', profile

			initialize: () ->
				super
				@setItem {id: 1, profile: 1, articles: 1}

		expect user.getItem(1).get('profile')
		.to.not.exist

	it 'should not dereference when using Raw methods', () ->

		profile = new class ProfileStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, name: 'John Doe'}

		article = new class ArticleStore extends EntityStore

			initialize: () ->
				super
				@setItem {id: 1, title: 'test article'}

		usersArticles = new class UserArticleStore extends IndexedListStore

			containsEntity: article
			initialize: () ->
				super
				# User with id 1 has article with id 1
				@add 1, 1

		user = new class UserStore extends EntityStore

			@hasOne 'profile', profile
			@hasMany('articles').through(usersArticles)

			dereference: sinon.spy()

			initialize: () ->
				super
				@setItem {id: 1, profile: 1, articles: 1}

				item = @getRawItem(1)

				expect item
				.to.exist

				expect item.get('profile')
				.to.equal 1

				expect item.get('articles')
				.to.equal 1

				expect item.getIn ['profile', 'name']
				.to.equal undefined

				expect item.getIn ['articles', 0, 'title']
				.to.equal undefined

				expect @dereference.called
				.to.equal false

				list = @getRawItemsWithIds([1])

				expect list
				.to.exist

				expect list.get(0)
				.to.exist

				expect list.get(0).get('profile')
				.to.equal 1

				expect list.get(0).get('articles')
				.to.equal 1

				expect list.get(0).getIn ['profile', 'name']
				.to.equal undefined

				expect list.get(0).getIn ['articles', 0, 'title']
				.to.equal undefined

				expect @dereference.called
				.to.equal false
