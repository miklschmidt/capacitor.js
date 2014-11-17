describe 'Dispatcher', () ->

	storeA = null
	storeB = null
	dispatcher = null
	action = null
	payload = null

	expectBothStoreCalls = (action, payload, waitFor) ->
		# StoreA
		expect storeA._handleAction.callCount
		.to.equal 1, 
			"storeA._handleAction wasn't executed once"

		expect storeA._handleAction.args[0]
		.to.be.deep.equal [action, payload, waitFor], 
			"storeA._handleAction wasn't executed with the right arguments"

		expect (storeA._handleAction.calledOn storeA), 
			"storeA._handleAction was not executed with the right context"
		.to.be.true

		# StoreB
		expect storeB._handleAction.callCount
		.to.equal 1, 
			"storeB._handleAction wasn't executed once"

		expect storeB._handleAction.args[0]
		.to.be.deep.equal [action, payload, waitFor], 
			"storeB._handleAction wasn't executed with the right arguments"

		expect (storeB._handleAction.calledOn storeB), 
			"storeB._handleAction was not executed with the right context"
		.to.be.true

	beforeEach () ->
		requirejs.undef('dispatcher')
		dispatcher = requirejs('dispatcher')
		storeA = _handleAction: sinon.spy()
		storeB = _handleAction: sinon.spy()
		action = "test-action"
		payload = {test: true}

	it 'should execute all subscriber callbacks', () ->
		dispatcher.register storeA
		dispatcher.register storeB

		dispatcher.dispatch action, payload

		expectBothStoreCalls action, payload, dispatcher.waitFor

	it 'should wait for stores registered earlier', () ->

		dispatcher.register storeA

		dispatcher.register _handleAction: (actionName, payload, waitFor) ->
			waitFor storeA

			expect storeA._handleAction.callCount
			.to.equal 1,
				"storeA._handleAction didn't execute before storeB._handleAction"
			expect storeA._handleAction.args[0]
			.to.be.deep.equal [action, payload, waitFor], 
				"storeA._handleAction wasn't executed with the right arguments before storeB._handleAction"

			storeB._handleAction arguments...

		dispatcher.dispatch action, payload

		expectBothStoreCalls action, payload, dispatcher.waitFor


	it 'should wait for stores registered later', () ->

		dispatcher.register _handleAction: (actionName, payload, waitFor) ->

			waitFor storeA
			
			expect storeA._handleAction.callCount
			.to.equal 1,
				"storeA._handleAction didn't execute before storeB._handleAction"

			expect storeA._handleAction.args[0]
			.to.be.deep.equal [action, payload, dispatcher.waitFor], 
				"storeA._handleAction wasn't executed with the right arguments before storeB._handleAction"

			storeB._handleAction arguments...

		dispatcher.register storeA

		dispatcher.dispatch action, payload

		expectBothStoreCalls action, payload, dispatcher.waitFor

	it 'should throw if dispatch is executed while dispatching', () ->

		dispatcher.register _handleAction: (actionName, payload, waitFor) ->
			dispatcher.dispatch action, payload
			storeA._handleAction arguments...

		expect () -> dispatcher.dispatch action, payload
		.to.throw Error

	it 'should throw if waitFor is called while not dispatching', () ->

		dispatcher.register storeA

		expect () -> dispatcher.waitFor storeA
		.to.throw(Error)

		expect storeA._handleAction.callCount
		.to.equal 0, 
			"storeA._handleAction was executed"

	it 'should throw if waitFor is called with an unregistered store', () ->

		dispatcher.register _handleAction: (actionName, payload, waitFor) ->
			waitFor storeB
			storeA._handleAction()

		expect () -> dispatcher.dispatch action, payload
		.to.throw(Error)

		expect storeA._handleAction.callCount
		.to.equal 0, 
			"storeA._handleAction was executed"

	it 'should throw on self-circular dependencies', () ->

		storeA = _handleAction: (actionName, payload, waitFor) ->
			waitFor storeA

		dispatcher.register storeA

		expect () -> dispatcher.dispatch action, payload
		.to.throw(Error)

	it 'should throw on multi-circular dependencies', () ->
		storeA = _handleAction: (actionName, payload, waitFor) ->
			waitFor storeB

		storeB = _handleAction: (actionName, payload, waitFor) ->
			waitFor storeA

		dispatcher.register storeA
		dispatcher.register storeB

		expect () -> dispatcher.dispatch action, payload
		.to.throw(Error)

	it 'should remain in a consistent state after a failed dispatch', () ->
		dispatcher.register storeA
		dispatcher.register _handleAction: (actionName, payload, waitFor) ->
			if payload.shouldThrow
				throw new Error()
			storeB._handleAction arguments...

		expect () ->
			dispatcher.dispatch action, shouldThrow: yes
		.to.throw(Error)

		storeACallbackCount = storeA._handleAction.callCount

		dispatcher.dispatch action, shouldThrow: no

		expect storeA._handleAction.callCount
		.to.be.equal storeACallbackCount + 1
		expect storeB._handleAction.callCount
		.to.be.equal 1

	it 'should properly unregister callbacks', () ->
		dispatcher.register storeA
		dispatcher.register storeB

		dispatcher.dispatch action, payload

		expectBothStoreCalls action, payload, dispatcher.waitFor

		dispatcher.unregister storeB

		dispatcher.dispatch action, payload

		expect storeA._handleAction.callCount
		.to.equal 2, 
			"storeA._handleAction wasn't executed twice"

		expect storeA._handleAction.args[1]
		.to.be.deep.equal [action, payload, dispatcher.waitFor], 
			"storeA._handleAction wasn't executed with the right arguments the second time"

		# StoreB
		expect storeB._handleAction.callCount
		.to.equal 1, 
			"storeB._handleAction wasn't only executed once"



