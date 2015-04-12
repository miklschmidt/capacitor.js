module.exports = class InvariantError extends Error

	constructor: (message) ->
		this.name = "Invariant Error"
		this.message = message
