Action        = require '../src/action'
ActionCreator = require '../src/action-creator'
{expect}      = require 'chai'

describe 'EventBroker', () ->

	EventBroker = null
	dispatcher = null
	action = null
	actionCreator = null
	payload = null

	beforeEach () ->
		if require.cache[require.resolve('../src/dispatcher')]
			delete require.cache[require.resolve('../src/dispatcher')]
			delete require.cache[require.resolve('../src/event-broker')]
		dispatcher = require('../src/dispatcher')
		EventBroker = require '../src/event-broker'
		action = new Action("test-action")
		actionCreator = new ActionCreator
		payload = {test: true}

	it 'should be able to handle listeners being removed while dispatching - removing listener before it has been dispatched', () ->
		broker = EventBroker()
		ctx = {}

		firstHandlerCalled = false
		secondHandlerCalled = false

		firstHandler = () ->
			firstHandlerCalled = true
			broker.remove secondHandler, ctx

		secondHandler = () ->
			secondHandlerCalled = true

		broker.add firstHandler, ctx
		broker.add secondHandler, ctx

		broker.dispatch()

		expect(firstHandlerCalled).to.be.true
		expect(secondHandlerCalled).to.be.false

	it 'should be able to handle listeners being removed while dispatching - removing listener after it has been dispatched', () ->
		broker = EventBroker()
		ctx = {}

		firstHandlerCalled = false
		secondHandlerCalled = false

		firstHandler = () ->
			firstHandlerCalled = true

		secondHandler = () ->
			secondHandlerCalled = true
			broker.remove firstHandler, ctx

		broker.add firstHandler, ctx
		broker.add secondHandler, ctx

		broker.dispatch()

		expect(firstHandlerCalled).to.be.true
		expect(secondHandlerCalled).to.be.true

	it 'should be able to handle listeners being removed while dispatching immediate - removing listener before it has been dispatched', () ->
		broker = EventBroker()
		ctx = {}

		firstHandlerCalled = false
		secondHandlerCalled = false

		firstHandler = () ->
			firstHandlerCalled = true
			broker.removeImmediate secondHandler, ctx

		secondHandler = () ->
			secondHandlerCalled = true

		broker.addImmediate firstHandler, ctx
		broker.addImmediate secondHandler, ctx

		broker.dispatch()

		expect(firstHandlerCalled).to.be.true
		expect(secondHandlerCalled).to.be.false

	it 'should be able to handle listeners being removed while dispatching immediate - removing listener after it has been dispatched', () ->
		broker = EventBroker()
		ctx = {}

		firstHandlerCalled = false
		secondHandlerCalled = false

		firstHandler = () ->
			firstHandlerCalled = true

		secondHandler = () ->
			secondHandlerCalled = true
			broker.removeImmediate firstHandler, ctx

		broker.addImmediate firstHandler, ctx
		broker.addImmediate secondHandler, ctx

		broker.dispatch()

		expect(firstHandlerCalled).to.be.true
		expect(secondHandlerCalled).to.be.true

	it 'should be able to handle listeners being removed while dispatcher is dispatching - removing listener before it has been dispatched', () ->
		broker = EventBroker()
		ctx = {}

		firstHandlerCalled = false
		secondHandlerCalled = false

		firstHandler = () ->
			firstHandlerCalled = true
			broker.remove secondHandler, ctx

		secondHandler = () ->
			secondHandlerCalled = true

		broker.add firstHandler, ctx
		broker.add secondHandler, ctx

		dispatcher.register {
			_handleAction: () ->
				expect(dispatcher.isDispatching()).to.be.true
				broker.dispatch()
				expect(firstHandlerCalled).to.equal false, "First handler"
				expect(secondHandlerCalled).to.equal false, "Second handler"
		}

		actionInstance = actionCreator.createActionInstance(action, payload)
		dispatcher.dispatch actionInstance

		expect(firstHandlerCalled).to.be.true
		expect(secondHandlerCalled).to.be.false

	it 'should be able to handle listeners being removed while dispatcher is dispatching - removing listener after it has been dispatched', () ->
		broker = EventBroker()
		ctx = {}

		firstHandlerCalled = false
		secondHandlerCalled = false

		firstHandler = () ->
			firstHandlerCalled = true

		secondHandler = () ->
			secondHandlerCalled = true
			broker.remove firstHandler, ctx

		broker.add firstHandler, ctx
		broker.add secondHandler, ctx

		dispatcher.register {
			_handleAction: () ->
				expect(dispatcher.isDispatching()).to.be.true
				broker.dispatch()
				expect(firstHandlerCalled).to.equal false, "First handler"
				expect(secondHandlerCalled).to.equal false, "Second handler"
		}

		actionInstance = actionCreator.createActionInstance(action, payload)
		dispatcher.dispatch actionInstance

		expect(firstHandlerCalled).to.be.true
		expect(secondHandlerCalled).to.be.true
