define [
	'dispatcher'
	'action-manager'
	'store'
	'invariant'
	'signals'
], (dispatcher, actionManager, Store, invariant, {Signal}) ->

	return {
		dispatcher
		actionManager
		Store
		invariant
		Signal
	}
