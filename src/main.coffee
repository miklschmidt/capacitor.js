define [
	'dispatcher'
	'action-manager'
	'store'
	'invariant'
	'logger'
], (dispatcher, actionManager, Store, invariant, logger) ->

	return {
		dispatcher
		actionManager
		Store
		invariant
		logger
	}