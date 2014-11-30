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
