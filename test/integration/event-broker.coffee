IndexedListStore = require '../../src/indexed-list-store'
EntityStore = require '../../src/entity-store'
ActionCreator = require '../../src/action-creator'
actionManager = require '../../src/action-manager'

sinon = require 'sinon'
expect = require('chai').expect

describe 'EventBroker', () ->

	it "should only dispatch one change event even though multiple dispatches happen inside a dispatch loop", () ->

		action = actionManager.create 'changed-test-action'

		instance = new class TestStore extends IndexedListStore

			containsEntity: new EntityStore
			@action action, () ->
				@changed()
				@changed()
				@changed.dispatch()

		changed = sinon.spy()
		instance.changed.add changed

		creator = new class TestActionCreator extends ActionCreator
		creator.dispatch action

		expect changed.callCount
		.to.equal 1

	it "should not batch change events when the store changes outside of a dispatch loop", () ->

		changed = sinon.spy()
		instance = new class TestStore extends IndexedListStore

			containsEntity: new EntityStore

			initialize: () ->
				super
				@changed.add changed
				@changed()
				@changed.dispatch()

		expect changed.callCount
		.to.equal 2


	it "every change event should be dispatched to immediate listeners", () ->

		action = actionManager.create 'changed-test-action-2'
		changed = sinon.spy()

		instance = new class TestStore extends IndexedListStore

			containsEntity: new EntityStore
			@action action, () ->
				@changed()
				@changed()
				@changed.dispatch()

			initialize: () ->
				super
				@changed.addImmediate changed
				@changed()
				@changed.dispatch()

		creator = new class TestActionCreator extends ActionCreator
		creator.dispatch action

		expect changed.callCount
		.to.equal 5