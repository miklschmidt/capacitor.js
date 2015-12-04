dispatcher = require './dispatcher'
invariant = require './invariant'

module.exports = () ->

	_listeners = []
	_immediateListeners = []
	shouldTrigger = no

	EventBroker = () ->
		EventBroker.dispatch()

	EventBroker.add = (fn, context = null) ->
			unless context?
				console.error "Warning: You should supply context to changed.add(...) as a second parameter."
			_listeners.push {fn, context}

	EventBroker.remove = (fn, context = null) ->
			listeners = []
			unless context?
				console.error "Warning: You should supply context to changed.remove(...) as a second parameter. Not doing so will remove listeners from all instances of your component."
			for listener, index in _listeners when listener.fn isnt fn and listener.context isnt context
				listeners.push listener
			_listeners = listeners

	EventBroker.addImmediate = (fn, context) ->
			unless context?
				console.error "Warning: You should supply context to changed.addImmediate(...) as a second parameter."
			_immediateListeners.push {fn, context}

	EventBroker.removeImmediate = (fn, context = null) ->
			listeners = []
			unless context?
				console.error "Warning: You should supply context to changed.removeImmediate(...) as a second parameter. Not doing so will remove listeners from all instances of your component."
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
					if listener.context? then listener.fn.apply(listener.context) else listener.fn()
			# Make sure all immediate listeners are called.
			EventBroker.dispatchImmediate()

	EventBroker.dispatchImmediate = (args...) ->
			for listener in _immediateListeners
				if listener.context? then listener.fn.apply(listener.context, args) else listener.fn()

	dispatcher.onFinalize () ->
		if shouldTrigger is yes
			for listener in _listeners
				if listener.context? then listener.fn.apply(listener.context) else listener.fn()
		shouldTrigger = no

	return EventBroker
