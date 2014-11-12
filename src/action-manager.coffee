define [
	'invariant'
	'dispatcher'
	'action'
], (invariant, dispatcher, Action) ->

	class ActionManager

		actions = {}

		create: (name) ->
			invariant !actions[name],
				"Action names are unique.",
				"An action with the name"
				name,
				"already exists."

			actions[name] = new Action name
			return actions[name]

		list: () ->
			return name for own name of actions

		exists: (name) ->
			return actions[name]?

	return new ActionManager