Action     = require('../src/action')
dispatcher = require('../src/dispatcher')
{expect}   = require 'chai'

describe 'Action', () ->

	it "should result in it's name when coerced to a string", () ->

		name = "test-action"
		action = new Action(name)
		expect(action+"").to.equal(name)