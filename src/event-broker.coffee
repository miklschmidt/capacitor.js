dispatcher = require './dispatcher'
invariant = require './invariant'

module.exports = () ->

	_listeners = []
	_immediateListeners = []
	shouldTrigger = no

	EventBroker = () ->
		EventBroker.dispatch()

	EventBroker.add = (fn, context = null) ->
			_listeners.push {fn, context}

	EventBroker.remove = (fn, context = null) ->
			listeners = []
			for listener, index in _listeners when listener.fn isnt fn and listener.context isnt context
				listeners.push listener
			_listeners = listeners

	EventBroker.addImmediate = (fn, context) ->
			_immediateListeners.push {fn, context}

	EventBroker.removeImmediate = (fn, context = null) ->
			listeners = []
			for listener, index in _immediateListeners when listener.fn isnt fn and listener.context isnt context
				listeners.push listener
			_immediateListeners = listeners

	EventBroker.dispatch = (args...) ->
			invariant args.length is 0, """
				EventBroker.dispatch(...): You can't dispatch with a payload. 
				This is due to events being batched by the dispatcher, to avoid unnecessary computations. 
				If you have a good reason to send a payload, you can use the unbatched dispatchImmediate and addImmediate.
			"""
			# if we're inside a dispatch loop, batch the change events. 
			# If not, go ahead and call the listeners.
			if dispatcher.isDispatching()
				shouldTrigger = yes
			else
				for listener in _listeners
					listener.fn()
			# Make sure all immediate listeners are called.
			EventBroker.dispatchImmediate()

	EventBroker.dispatchImmediate = (args...) ->
			for listener in _immediateListeners
				listener.fn args...

	dispatcher.onFinalize () ->
		if shouldTrigger is yes
			for listener in _listeners
				listener.fn()
		shouldTrigger = no

	return EventBroker