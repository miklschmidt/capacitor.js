ActionCreator = require '../src/action-creator'
Action        = require '../src/action'
dispatcher    = require '../src/dispatcher'
{expect}      = require 'chai'
sinon      = require 'sinon'

describe 'ActionCreator', () ->

	before () ->
		sinon.spy dispatcher, "dispatch"

	after () ->
		dispatcher.dispatch.restore()

	it 'should dispatch the action through the dispatcher upon calling dispatch with an action', () ->
		action = new Action("test-action")
		actionCreator = new ActionCreator
		actionCreator.dispatch action

		expect(dispatcher.dispatch.calledOnce, "dispatcher wasn't called").to.be.true