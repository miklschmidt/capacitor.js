Store          = require('../src/store')
Action         = require('../src/action')
ActionCreator  = require('../src/action-creator')
InvariantError = require('../src/invariant-error')
_              = require('lodash')
{expect}       = require 'chai'
sinon          = require 'sinon'
Immutable      = require 'immutable'

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

	it 'should call initialize on instantiation and throw when super was not called', () ->

		init = sinon.spy()

		class TestStore extends Store

			initialize: init

		expect () -> new TestStore
		.to.throw InvariantError

		expect init.calledOnce
		.to.be.true


	it 'should hook up action handlers correctly', () ->
		testFunction = () -> true

		class TestStore extends Store

			@action new Action('test'), testFunction

			initialize: () ->
				super
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
		actionCreator = new ActionCreator
		handler = sinon.spy()
		class TestStore extends Store

			@action action, handler

			initialize: () ->
				super
				@_handleAction actionCreator.createActionInstance(action), () -> true

		instance = new TestStore

		expect handler.callCount
		.to.equal 1,
			"action handler wasn't executed"

	it 'should ignore unknown actions', () ->
		firstAction = new Action('test')
		secondAction = new Action('test2')
		actionCreator = new ActionCreator
		handler = sinon.spy()
		class TestStore extends Store

			@action secondAction, handler

			initialize: () ->
				super
				@_handleAction actionCreator.createActionInstance(firstAction), () -> true


		instance = new TestStore

		expect handler.callCount
		.to.equal 0,
			"action handler for another action was executed, something is very wrong"

	it 'should work without actions', () ->
		class TestStore extends Store

			initialize: () ->
				super
				@_handleAction (new ActionCreator).createActionInstance(new Action('test')), () -> true

		instance = new TestStore


	it 'should be able to set a single property', () ->
		class TestStore extends Store

			initialize: () ->
				super
				@set 'test', 'test'

		instance = new TestStore

		expect instance.get 'test'
		.to.equal 'test'

	it 'should be able to set an object', () ->
		class TestStore extends Store

			initialize: () ->
				super
				@set {a: 'test', b: 'test2'}

		instance = new TestStore

		expect instance.get 'a'
		.to.equal 'test'

		expect instance.get 'b'
		.to.equal 'test2'

	it 'should be able to use an existing immutable object when setting', () ->
		obj = Immutable.fromJS({a: 'test'})
		class TestStore extends Store

			initialize: () ->
				super
				@set {a: 'test', b: obj}

		instance = new TestStore

		testObj = instance.get 'b'

		expect testObj
		.to.equal obj

	it 'should be able to get a single property', () ->

		class TestStore extends Store

			initialize: () ->
				super
				@set {items: [], a: 'test'}

		instance = new TestStore

		expect _.isArray(instance.get('items').toJS())
		.to.be.true

		expect instance.get 'a'
		.to.equal 'test'

	it 'should dereference objects in get/set', () ->
		nestedObject =
			a:
				b:
					c: "test"
				d: ['test', 'test', 'test']
			d: "test"

		class TestStore extends Store

			initialize: () ->
				super
				@set nestedObject

				nestedObject.a.b.c = "shouldntchangestoreprops"
				expect @getIn(['a', 'b', 'c'])
				.to.be.equal "test"


		instance = new TestStore

		obj = instance.getIn(['a', 'b'])

		expect obj.get('c')
		.to.be.equal "test"

	it 'should properly clone date objects', () ->
		data = date: new Date()

		class TestStore extends Store

			initialize: () ->
				super
				@set data
				expect (@get 'date').getTime
				.to.exist

		instance = new TestStore

		data.date = new Date()

		expect data.date
		.to.not.be.equal instance.get('date')


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
				super
				@set nestedObject
				@merge mergeObject


		instance = new TestStore

		result = instance.get()

		expect result.toJS()
		.to.have.keys ["a", "d", "f", "x"]

		expect result.get('a').toJS()
		.to.have.keys ['b']

		expect result.getIn(['a', 'b']).toJS()
		.to.have.keys ['c', 'e']

		expect result.getIn(['a', 'b', 'e'])
		.to.equal 'test2'

		expect result.getIn(['a', 'b', 'c'])
		.to.equal 'test'

		expect result.get('d')
		.to.equal "test3"

		expect result.get('f')
		.to.equal "another"

		expect result.get('x')
		.to.equal "test4"

	it 'should be able to wait for another store', () ->
		action = new Action("test")
		actionCreator = new ActionCreator
		works = no

		class TestStore extends Store
			@action action, (payload, waitFor) ->
				waitFor(instanceB)
				expect works
				.to.be.true

		class TestStoreB extends Store
			@action action, (payload, waitFor) -> works = yes

		instance = new TestStore
		instanceB = new TestStoreB

		actionCreator.dispatch action

	it 'should be able to get action id within an action handler', () ->
		action = new Action("test")
		actionCreator = new ActionCreator
		currentID = null

		class TestStore extends Store

			@action action, (payload, waitFor) ->
				reportedID = @getCurrentActionID

				expect reportedID
				.to.be.equal currentID

				expect reporedID
				.to.not.be null

		currentID = actionCreator.dispatch(action).actionID
