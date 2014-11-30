Store = requirejs('store')
Action = requirejs('action')
InvariantError = requirejs('invariant-error')

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

	it 'should hook up action handlers correctly', () ->
		testFunction = () -> true
		class TestStore extends Store

			@action new Action('test'), testFunction


		expect TestStore._handlers['test']
		.to.exist

		expect TestStore._handlers['test']
		.to.equal testFunction

		instance = new TestStore

		expect instance.constructor._handlers['test']
		.to.exist

		expect instance.constructor._handlers['test']
		.to.equal testFunction

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

		instance = new TestStore

		instance._handleAction 'test', {}, () -> true

		expect handler.callCount
		.to.equal 1,
			"action handler wasn't executed"

	it 'should be able to set a single property', () ->
		class TestStore extends Store

		instance = new TestStore

		instance.set 'test', 'test'
		expect instance.get 'test'
		.to.equal 'test'

	it 'should be able to set an object', () ->
		class TestStore extends Store

		instance = new TestStore

		instance.set {a: 'test', b: 'test2'}

		expect instance.get 'a'
		.to.equal 'test'

		expect instance.get 'b'
		.to.equal 'test2'

	it 'should be able to get an array of values', () ->
		class TestStore extends Store

		instance = new TestStore

		instance.set {a: 'test', b: 'test2'}

		val = instance.get ['a', 'b']
		expect val
		.to.have.keys ['a', 'b']

		expect val.a
		.to.equal 'test'

		expect val.b
		.to.equal 'test2'


	it 'should dereference objects in get/set', () ->
		class TestStore extends Store

		nestedObject =
			a:
				b:
					c: "test"
			d: "test"

		instance = new TestStore

		instance.set nestedObject
		nestedObject.a.b.c = "shouldntchangestoreprops"
		expect instance._properties.a.b.c
		.to.be.equal "test"

		obj = instance.get('a').b

		expect obj.c
		.to.be.equal "test"

		obj.c = "shouldntchangestorepropseither"

		expect instance.get('a').b.c
		.to.be.equal "test"

	it 'should be able to merge existing props with an object', () ->
		class TestStore extends Store

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

		instance = new TestStore

		instance.set nestedObject
		instance.merge mergeObject

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
		class TestStore extends Store

		instance = new TestStore

		cb = sinon.spy()
		instance.changed.add cb
		instance.set 'test', 'test'



