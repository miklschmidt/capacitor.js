dispatcher = require './dispatcher'

class Action

	###*
	* Constructor
	*
	* @param {string} The name of the action
	###
	constructor: (@type) ->
		
	###*
	* Magic method for coercing an action to a string
	###
	toString: () -> @type

module.exports = Action