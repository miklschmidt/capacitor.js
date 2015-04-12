Action   = require('../src/action')
{expect} = require 'chai'

describe 'ActionManager', () ->

	actionManager = null

	beforeEach () ->
		if require.cache[require.resolve('../src/action-manager')]?
			delete require.cache[require.resolve('../src/action-manager')]
		actionManager = require('../src/action-manager')

	it 'should create an action when calling create', () ->
		action = actionManager.create 'test'
		expect action
		.to.be.instanceOf Action

	it 'should throw when creating an action with the same name twice', () ->
		action = actionManager.create 'test'
		expect () ->
			action2 = actionManager.create 'test'
		.to.throw Error

	it 'should be able to tell wether an action exists', () ->
		action = actionManager.create 'test'
		expect actionManager.exists 'test'
		.to.be.true

		expect actionManager.exists 'test2'
		.to.be.false

	it 'should be able to list all current actions', () ->
		actions = ['1', '2', '3', '4', '5']
		for action in actions
			actionManager.create action

		expect actionManager.list()
		.to.include.members actions
