invariant  = require './invariant'
dispatcher = require './dispatcher'
Action     = require './action'

module.exports = new class ActionManager

	###
	# @var {Object} actions a list of all existing actions
	# @private
	###
	actions = {}

	###
	# Method for creating an action
	#
	# @param {string} name The (unique) name of the action.
	# @return {Action} the created action.
	###
	create: (name) ->
		invariant !actions[name],
			"Action names are unique. An action with the name #{name} already exists."

		actions[name] = new Action name
		return actions[name]

	###
	# Method for listing all existing actions
	#
	# @return {Array} list of existing actions
	###
	list: () ->
		name for own name of actions

	###
	# Method to check if an action exists
	#
	# @return {boolean}
	###
	exists: (name) ->
		return actions[name]?