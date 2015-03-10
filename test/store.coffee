Store = requirejs('store')
Action = requirejs('action')
InvariantError = requirejs('invariant-error')
_ = requirejs('lodash')

describe 'Store', () ->

	it 'should throw on invalid action call', () ->
		expect () ->
			class TestStore extends Store
				@action 'invalid', () ->
		.to.throw InvariantError

		expect () ->
			class TestStore2 extends Store
				@action {also: "invalid"}, () ->
		.to.throw InvariantError

	it 'should warn when action handler is a prototype method', () ->

		sinon.stub console, 'warn'

		class TestStore2 extends Store

			test: () ->

			@action new Action('test'), @::test

		expect console.warn.calledOnce
		.to.be.true

		console.warn.restore()

	it 'should call initialize on instantiation', () ->

		init = sinon.spy()

		class TestStore extends Store

			initialize: init

		new TestStore

		expect init.calledOnce
		.to.be.true


	it 'should hook up action handlers correctly', () ->
		testFunction = () -> true

		class TestStore extends Store

			@action new Action('test'), testFunction

			initialize: () ->
				expect @constructor._handlers['test']
				.to.exist

				expect @constructor._handlers['test']
				.to.equal testFunction

		expect TestStore._handlers['test']
		.to.exist

		expect TestStore._handlers['test']
		.to.equal testFunction

		instance = new TestStore


	it 'should throw when hooking up the same action twice', () ->
		action = new Action('test')
		expect () ->
			class TestStore extends Store

				@action action, () ->
				@action action, () ->
		.to.throw InvariantError

	it 'should execute action handlers when actions are dispatched', () ->
		action = new Action('test')
		handler = sinon.spy()
		class TestStore extends Store

			@action action, handler

			initialize: () ->
				@_handleAction 'test', {}, () -> true

		instance = new TestStore

		expect handler.callCount
		.to.equal 1,
			"action handler wasn't executed"

	it 'should ignore unknown actions', () ->
		firstAction = new Action('test')
		secondAction = new Action('test2')
		handler = sinon.spy()
		class TestStore extends Store

			@action secondAction, handler

			initialize: () ->
				@_handleAction 'test', {}, () -> true


		instance = new TestStore

		expect handler.callCount
		.to.equal 0,
			"action handler for another action was executed, something is very wrong"

	it 'should work without actions', () ->
		class TestStore extends Store

			initialize: () ->
				@_handleAction 'test', {}, () -> true

		instance = new TestStore


	it 'should be able to set a single property', () ->
		class TestStore extends Store

			initialize: () ->
				@set 'test', 'test'

		instance = new TestStore

		expect instance.get 'test'
		.to.equal 'test'

	it 'should be able to set an object', () ->
		class TestStore extends Store

			initialize: () ->
				@set {a: 'test', b: 'test2'}

		instance = new TestStore

		expect instance.get 'a'
		.to.equal 'test'

		expect instance.get 'b'
		.to.equal 'test2'

	it 'should be able to get a single property', () ->

		class TestStore extends Store

			initialize: () ->
				@set {items: [], a: 'test'}

		instance = new TestStore

		expect _.isArray(instance.get('items'))
		.to.be.true

		expect instance.get 'a'
		.to.equal 'test'

	it 'should be able to get an array of values', () ->
		class TestStore extends Store

			initialize: () ->
				@set {a: 'test', b: 'test2'}


		instance = new TestStore

		val = instance.get ['a', 'b']
		expect val
		.to.have.keys ['a', 'b']

		expect val.a
		.to.equal 'test'

		expect val.b
		.to.equal 'test2'

	it 'should dereference objects in get/set', () ->
		nestedObject =
			a:
				b:
					c: "test"
				d: ['test', 'test', 'test']
			d: "test"

		class TestStore extends Store

			initialize: () ->
				@set nestedObject

				nestedObject.a.b.c = "shouldntchangestoreprops"
				expect @_properties.a.b.c
				.to.be.equal "test"


		instance = new TestStore

		obj = instance.get('a').b

		expect obj.c
		.to.be.equal "test"

		obj.c = "shouldntchangestorepropseither"

		expect instance.get('a').b.c
		.to.be.equal "test"

	it 'should be able to merge existing props with an object', () ->

		nestedObject =
			a:
				b:
					c: "test"
			d: "test"
			x: "test4"

		mergeObject =
			a:
				b:
					e: "test2"
			d: "test3"
			f: "another"

		class TestStore extends Store

			initialize: () ->
				@set nestedObject
				@merge mergeObject


		instance = new TestStore

		result = instance.get()

		expect result
		.to.have.keys ["a", "d", "f", "x"]

		expect result.a
		.to.have.keys ['b']

		expect result.a.b
		.to.have.keys ['c', 'e']

		expect result.a.b.e
		.to.equal 'test2'

		expect result.a.b.c
		.to.equal 'test'

		expect result.d
		.to.equal "test3"

		expect result.f
		.to.equal "another"

		expect result.x
		.to.equal "test4"

	it 'should dispatch changed signal on set', () ->
		that = null
		class TestStore extends Store

			initialize: () ->
				that = @

		instance = new TestStore
		cb = sinon.spy()
		instance.changed.add cb
		that.set 'test', 'test'

	it 'should be able to wait for another store', () ->
		action = new Action("test")

		works = no

		class TestStore extends Store
			@action action, (waitFor) ->
				waitFor(instanceB)
				expect works
				.to.be.true

		class TestStoreB extends Store
			@action action, (waitFor) -> works = yes

		instance = new TestStore
		instanceB = new TestStoreB

		action.dispatch()

