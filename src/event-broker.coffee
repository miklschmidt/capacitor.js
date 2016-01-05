dispatcher = require './dispatcher'
invariant = require './invariant'

module.exports = () ->

	_listeners = []
	_immediateListeners = []
	shouldTrigger = no
	removedListenerSinceLastDispatch = []
	removedImmediateListenerSinceLastDispatch = []

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
			for listener, index in _listeners
				if listener.fn isnt fn and listener.context isnt context
					listeners.push listener
				else
					removedListenerSinceLastDispatch.push listener
			_listeners = listeners

	EventBroker.addImmediate = (fn, context) ->
			unless context?
				console.error "Warning: You should supply context to changed.addImmediate(...) as a second parameter."
			_immediateListeners.push {fn, context}

	EventBroker.removeImmediate = (fn, context = null) ->
			listeners = []
			unless context?
				console.error "Warning: You should supply context to changed.removeImmediate(...) as a second parameter. Not doing so will remove listeners from all instances of your component."
			for listener, index in _immediateListeners
				if listener.fn isnt fn and listener.context isnt context
					listeners.push listener
				else
					removedImmediateListenerSinceLastDispatch.push listener
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
				listeners = _listeners.slice 0
				removedListenerSinceLastDispatch = []
				# Allow removing listeners while looping through them
				# This means that removed listeners that has not yet been called
				# during this dispatch won't get called.
				# Also it means newly added dispatchers during the dispatching
				# won't ever get called
				for listener in listeners when listener not in removedListenerSinceLastDispatch
					if listener.context? then listener.fn.apply(listener.context) else listener.fn()
			# Make sure all immediate listeners are called.
			EventBroker.dispatchImmediate()

	EventBroker.dispatchImmediate = (args...) ->
		listeners = _immediateListeners.slice 0
		removedImmediateListenerSinceLastDispatch = []
		for listener in listeners when listener not in removedImmediateListenerSinceLastDispatch
			if listener.context? then listener.fn.apply(listener.context, args) else listener.fn()

	dispatcher.onFinalize () ->
		if shouldTrigger is yes
			listeners = _listeners.slice 0
			removedListenerSinceLastDispatch = []
			for listener in listeners when listener not in removedListenerSinceLastDispatch
				if listener.context? then listener.fn.apply(listener.context) else listener.fn()
		shouldTrigger = no

	return EventBroker
