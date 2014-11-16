define [
	'dispatcher'
	'action-manager'
	'store'
	'invariant'
], (dispatcher, actionManager, Store, invariant, logger) ->

	return {
		dispatcher
		actionManager
		Store
		invariant
	}