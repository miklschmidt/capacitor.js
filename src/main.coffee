define [
	'dispatcher'
	'action-manager'
	'store'
	'invariant'
	'signals'
], (dispatcher, actionManager, Store, invariant) ->

	return {
		dispatcher
		actionManager
		Store
		invariant
	}
