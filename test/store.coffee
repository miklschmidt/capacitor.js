Store = requirejs('store')
Action = requirejs('action')

describe 'Store', () ->

	it 'should throw when invalid actions array is provided', () ->
		class TestStore extends Store

			actions: [
				'invalid', () ->
			]

		class TestStore2 extends Store

			actions: [
				'so', 'is', 'this', () ->
			]

		expect () ->
			instance1 = new TestStore
		.to.throw Error

		expect () ->
			instance2 = new TestStore2
		.to.throw Error

	it 'should hook up action handlers correctly', () ->
		testFunction = () -> true
		class TestStore extends Store

			actions: [
				new Action('test'), testFunction
			]

		instance = new TestStore

		expect instance._handlers['test']
		.to.exist

		expect instance._handlers['test']
		.to.equal testFunction

	it 'should throw when hooking up the same action twice', () ->
		action = new Action('test')
		class TestStore extends Store

			actions: [
				action, () ->
				action, () ->
			]

		expect () ->
			instance = new TestStore
		.to.throw Error

	it 'should execute action handlers when actions are dispatched', () ->
		action = new Action('test')
		handler = sinon.spy()
		class TestStore extends Store

			actions: [
				action, handler
			]

		instance = new TestStore

		instance._handleAction 'test', {}, () -> true

		expect handler.callCount
		.to.equal 1, 
			"action handler wasn't executed"