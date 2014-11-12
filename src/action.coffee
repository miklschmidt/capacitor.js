define [
	'dispatcher'
], (dispatcher) ->

	class Action

		constructor: (@name) ->

		dispatch: (payload) -> dispatcher.dispatch @name, payload

		toString: () -> @name