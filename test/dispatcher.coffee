InvariantError = require('../src/invariant-error')
Action         = require('../src/action')
{expect}       = require 'chai'
sinon          = require 'sinon'

describe 'Dispatcher', () ->

	storeA = null
	storeB = null
	dispatcher = null
	action = null
	payload = null

	expectBothStoreCalls = (actionInstance, waitFor) ->
		# StoreA
		expect storeA._handleAction.callCount
		.to.equal 1,
			"storeA._handleAction wasn't executed once"

		expect storeA._handleAction.args[0]
		.to.be.deep.equal [actionInstance, waitFor],
			"storeA._handleAction wasn't executed with the right arguments"

		expect (storeA._handleAction.calledOn storeA),
			"storeA._handleAction was not executed with the right context"
		.to.be.true

		# StoreB
		expect storeB._handleAction.callCount
		.to.equal 1,
			"storeB._handleAction wasn't executed once"

		expect storeB._handleAction.args[0]
		.to.be.deep.equal [actionInstance, waitFor],
			"storeB._handleAction wasn't executed with the right arguments"

		expect (storeB._handleAction.calledOn storeB),
			"storeB._handleAction was not executed with the right context"
		.to.be.true

	beforeEach () ->
		if require.cache[require.resolve('../src/dispatcher')]
			delete require.cache[require.resolve('../src/dispatcher')]
		dispatcher = require('../src/dispatcher')
		storeA = _handleAction: sinon.spy()
		storeB = _handleAction: sinon.spy()
		action = new Action("test-action")
		payload = {test: true}

	it 'should execute all subscriber callbacks', () ->
		dispatcher.register storeA
		dispatcher.register storeB

		actionInstance = action.createActionInstance(payload)
		dispatcher.dispatch actionInstance
		expectBothStoreCalls actionInstance, dispatcher.waitFor

	it 'should wait for stores registered earlier', () ->

		dispatcher.register storeA

		dispatcher.register _handleAction: (actionInstance, waitFor) ->
			waitFor storeA

			expect storeA._handleAction.callCount
			.to.equal 1,
				"storeA._handleAction didn't execute before storeB._handleAction"
			expect storeA._handleAction.args[0]
			.to.be.deep.equal [actionInstance, waitFor],
				"storeA._handleAction wasn't executed with the right arguments before storeB._handleAction"

			storeB._handleAction arguments...

		actionInstance = action.createActionInstance(payload)
		dispatcher.dispatch actionInstance
		expectBothStoreCalls actionInstance, dispatcher.waitFor

	it 'should wait for stores registered later', () ->

		dispatcher.register _handleAction: (actionInstance, waitFor) ->

			waitFor storeA

			expect storeA._handleAction.callCount
			.to.equal 1,
				"storeA._handleAction didn't execute before storeB._handleAction"

			expect storeA._handleAction.args[0]
			.to.be.deep.equal [actionInstance, dispatcher.waitFor],
				"storeA._handleAction wasn't executed with the right arguments before storeB._handleAction"

			storeB._handleAction arguments...

		dispatcher.register storeA

		actionInstance = action.createActionInstance(payload)
		dispatcher.dispatch actionInstance
		expectBothStoreCalls actionInstance, dispatcher.waitFor

	it 'should throw if dispatch is executed while dispatching', () ->

		dispatcher.register _handleAction: (actionInstance, waitFor) ->
			dispatcher.dispatch action.createActionInstance(payload)
			storeA._handleAction arguments...

		expect () -> dispatcher.dispatch action.createActionInstance(payload)
		.to.throw InvariantError

	it 'should throw if waitFor is called while not dispatching', () ->

		dispatcher.register storeA

		expect () -> dispatcher.waitFor storeA
		.to.throw InvariantError

		expect storeA._handleAction.callCount
		.to.equal 0,
			"storeA._handleAction was executed"

	it 'should throw if waitFor is called with an unregistered store', () ->

		dispatcher.register _handleAction: (actionInstance, waitFor) ->
			waitFor storeB
			storeA._handleAction()

		expect () -> dispatcher.dispatch action.createActionInstance(payload)
		.to.throw InvariantError

		expect storeA._handleAction.callCount
		.to.equal 0,
			"storeA._handleAction was executed"

	it 'should throw on self-circular dependencies', () ->

		storeA = _handleAction: (actionInstance, waitFor) ->
			waitFor storeA

		dispatcher.register storeA

		expect () -> dispatcher.dispatch action.createActionInstance(payload)
		.to.throw InvariantError

	it 'should throw on multi-circular dependencies', () ->
		storeA = _handleAction: (actionInstance, waitFor) ->
			waitFor storeB

		storeB = _handleAction: (actionInstance, waitFor) ->
			waitFor storeA

		dispatcher.register storeA
		dispatcher.register storeB

		expect () -> dispatcher.dispatch action.createActionInstance(payload)
		.to.throw InvariantError

	it 'should remain in a consistent state after a failed dispatch', () ->
		dispatcher.register storeA
		dispatcher.register _handleAction: (actionInstance, waitFor) ->
			if actionInstance.payload.shouldThrow
				throw new Error()
			storeB._handleAction arguments...

		expect () ->
			dispatcher.dispatch action.createActionInstance(shouldThrow: yes)
		.to.throw Error

		storeACallbackCount = storeA._handleAction.callCount

		dispatcher.dispatch action.createActionInstance(shouldThrow: no)

		expect storeA._handleAction.callCount
		.to.be.equal storeACallbackCount + 1
		expect storeB._handleAction.callCount
		.to.be.equal 1

	it 'should properly unregister callbacks', () ->
		dispatcher.register storeA
		dispatcher.register storeB

		actionInstance = action.createActionInstance(payload)
		dispatcher.dispatch actionInstance
		expectBothStoreCalls actionInstance, dispatcher.waitFor

		dispatcher.unregister storeB

		actionInstance = action.createActionInstance(payload)
		dispatcher.dispatch actionInstance

		expect storeA._handleAction.callCount
		.to.equal 2,
			"storeA._handleAction wasn't executed twice"

		expect storeA._handleAction.args[1]
		.to.be.deep.equal [actionInstance, dispatcher.waitFor],
			"storeA._handleAction wasn't executed with the right arguments the second time"

		# StoreB
		expect storeB._handleAction.callCount
		.to.equal 1,
			"storeB._handleAction wasn't only executed once"

	it 'should allow dispatching actions without a payload', () ->
		dispatcher.dispatch action.createActionInstance()


	it 'should not send other arguments than waitFor if no data is dispatched', () ->
		called = false
		storeA = _handleAction: () ->
			called = true
			expect arguments.length
			.to.be.equal 2
			expect arguments[0].type
			.to.be.equal action.toString()
			expect arguments[1]
			.to.be.equal dispatcher.waitFor

		dispatcher.register storeA
		dispatcher.dispatch action.createActionInstance()

		expect called
		.to.be.true """Store's action handler wasn't called"""
