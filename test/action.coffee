Action     = require('../src/action')
dispatcher = require('../src/dispatcher')
{expect}   = require 'chai'
sinon      = require 'sinon'

describe 'Action', () ->

	before () ->
		sinon.spy dispatcher, "dispatch"

	after () ->
		dispatcher.dispatch.restore()

	it "should result in it's name when coerced to a string", () ->

		name = "test-action"
		action = new Action(name)
		expect(action+"").to.equal(name)

	it 'should call dispatch on the dispatcher when dispatched', () ->
		action = new Action("test-action")
		action.dispatch()

		expect(dispatcher.dispatch.calledOnce, "dispatcher wasn't called").to.be.true