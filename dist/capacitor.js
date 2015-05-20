/**
 * @license capacitor.js 0.2.0 Copyright (c) 2014, Mikkel Schmidt. All Rights Reserved.
 * Available via the MIT license.
 */

 (function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("lodash"), require("immutable"));
	else if(typeof define === 'function' && define.amd)
		define(["lodash", "immutable"], factory);
	else if(typeof exports === 'object')
		exports["capacitor"] = factory(require("lodash"), require("immutable"));
	else
		root["capacitor"] = factory(root["lodash"], root["immutable"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_6__, __WEBPACK_EXTERNAL_MODULE_7__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(1);


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	var ActionCreator, Store, actionManager, invariant;

	actionManager = __webpack_require__(2);

	ActionCreator = __webpack_require__(3);

	Store = __webpack_require__(4);

	invariant = __webpack_require__(5);

	module.exports = {
	  actionManager: actionManager,
	  ActionCreator: ActionCreator,
	  Store: Store,
	  invariant: invariant
	};


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	var Action, ActionManager, dispatcher, invariant,
	  __hasProp = {}.hasOwnProperty;

	invariant = __webpack_require__(5);

	dispatcher = __webpack_require__(8);

	Action = __webpack_require__(9);

	module.exports = new (ActionManager = (function() {

	  /*
	  	 * @var {Object} actions a list of all existing actions
	  	 * @private
	   */
	  var actions;

	  function ActionManager() {}

	  actions = {};


	  /*
	  	 * Method for creating an action
	  	 *
	  	 * @param {string} name The (unique) name of the action.
	  	 * @return {Action} the created action.
	   */

	  ActionManager.prototype.create = function(name) {
	    invariant(!actions[name], "Action names are unique. An action with the name " + name + " already exists.");
	    actions[name] = new Action(name);
	    return actions[name];
	  };


	  /*
	  	 * Method for listing all existing actions
	  	 *
	  	 * @return {Array} list of existing actions
	   */

	  ActionManager.prototype.list = function() {
	    var name, _results;
	    _results = [];
	    for (name in actions) {
	      if (!__hasProp.call(actions, name)) continue;
	      _results.push(name);
	    }
	    return _results;
	  };


	  /*
	  	 * Method to check if an action exists
	  	 *
	  	 * @return {boolean}
	   */

	  ActionManager.prototype.exists = function(name) {
	    return actions[name] != null;
	  };

	  return ActionManager;

	})());


/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	var Action, ActionCreator, ActionInstance, dispatcher, invariant, _actionID, _requestID;

	dispatcher = __webpack_require__(8);

	invariant = __webpack_require__(5);

	Action = __webpack_require__(9);

	_actionID = 0;

	_requestID = 0;

	ActionInstance = (function() {
	  function ActionInstance(type, payload) {
	    this.type = type;
	    this.payload = payload;
	    this.actionID = _actionID++;
	    Object.freeze(this);
	  }

	  ActionInstance.prototype.valueOf = function() {
	    return this.payload;
	  };

	  ActionInstance.prototype.getActionID = function() {
	    return this.actionID;
	  };

	  return ActionInstance;

	})();

	module.exports = ActionCreator = (function() {
	  function ActionCreator() {}


	  /*
	  	 * Dispatches an action through the dispatcher
	  	 *
	  	 * @param {Action} action The action to dispatch
	  	 * @param {mixed} payload Payload for the action
	   */

	  ActionCreator.prototype.dispatch = function(action, payload) {
	    var actionInstance;
	    actionInstance = this.createActionInstance(action, payload);
	    dispatcher.dispatch(actionInstance);
	    return actionInstance;
	  };


	  /*
	  	 * Creates an action instance for dispatching
	  	 *
	  	 * @param {Action} action The action to dispatch
	  	 * @param {mixed} payload Payload for the action
	   */

	  ActionCreator.prototype.createActionInstance = function(action, payload) {
	    invariant(action instanceof Action && ((action != null ? action.type : void 0) != null), "The action you dispatched does not seem to be an instance of capacitor.Action");
	    return new ActionInstance(action.type, payload);
	  };


	  /*
	  	 * Generates a request id. Useful for tracking specific requests in components.
	   */

	  ActionCreator.prototype.generateRequestID = function() {
	    return _requestID++;
	  };

	  return ActionCreator;

	})();


/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	var Action, Immutable, Signal, Store, cloneDeep, dispatcher, invariant, _,
	  __hasProp = {}.hasOwnProperty,
	  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
	  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

	_ = __webpack_require__(6);

	Signal = __webpack_require__(11).Signal;

	Action = __webpack_require__(9);

	dispatcher = __webpack_require__(8);

	invariant = __webpack_require__(5);

	Immutable = __webpack_require__(7);


	/*
	 *	implementation example:
	 *
	 *	class TodoStore extends Store
	 *		@action someAction, () ->
	 *			@doStuff()
	 *			@doOtherStuff()
	 *			@profit()
	 *
	 *		doStuff: () ->
	 *			# Do things..
	 *
	 *
	 *		doOtherStuff: () ->
	 *			# Do things..
	 *
	 *		profit: () ->
	 *			# Do things..
	 *			@changed.dispatch()
	 */

	cloneDeep = function(obj) {
	  var key, newObj, val, _i, _len;
	  if (!(_.isObject(obj) || _.isArray(obj))) {
	    return obj;
	  }
	  if (typeof window !== "undefined" && window !== null) {
	    if (obj instanceof window.Element) {
	      return obj;
	    }
	  }
	  if (obj instanceof Date) {
	    return new Date(obj.getTime());
	  }
	  newObj = null;
	  if (_.isObject(obj) && !_.isArray(obj)) {
	    newObj = {};
	    if ((obj.clone != null) && typeof obj.clone === 'function') {
	      newObj = obj.clone();
	    } else {
	      for (key in obj) {
	        if (!__hasProp.call(obj, key)) continue;
	        val = obj[key];
	        if (_.isObject(val) || _.isArray(val)) {
	          newObj[key] = cloneDeep(val);
	        } else {
	          newObj[key] = val;
	        }
	      }
	    }
	  } else {
	    newObj = [];
	    if ((obj.clone != null) && typeof obj.clone === 'function') {
	      newObj = obj.clone();
	    } else {
	      for (_i = 0, _len = obj.length; _i < _len; _i++) {
	        val = obj[_i];
	        newObj.push(cloneDeep(val));
	      }
	    }
	  }
	  return newObj;
	};

	module.exports = Store = (function() {

	  /*
	  	 * @static
	  	 * @private
	   */
	  Store._handlers = null;


	  /*
	  	 * @private
	   */

	  Store.prototype._properties = null;


	  /*
	  	 * @private
	   */

	  Store.prototype._currentActionInstance = null;


	  /*
	  	 * Static method for defining action handlers on a Store.
	  	 *
	  	 * @static
	  	 * @param {Action} action The Action to associated with the handler.
	  	 * @param {Function} fn The handler to call when Action is triggered.
	   */

	  Store.action = function(action, fn) {
	    var prop, _ref, _results;
	    if (this._handlers == null) {
	      this._handlers = {};
	    }
	    invariant(action instanceof Action && typeof fn === "function", "Store.action(...): Provided action should be created via the action manager and a handler must be given as a second parameter.\nIf you're trying to reference a prototype method, don't do that.");
	    invariant(this._handlers[action] == null, "Store.action(...): You can only define one handler pr action");
	    this._handlers[action] = fn;
	    _ref = this.prototype;
	    _results = [];
	    for (prop in _ref) {
	      if (!__hasProp.call(_ref, prop)) continue;
	      if (fn === this.prototype[prop]) {
	        _results.push(console.warn("Store.action(...): Action %s is referring to a method on the store prototype (%O).\nThis is bad practice and should be avoided.\nThe handler itself may call prototype methods,\nand is called with the store instance as context for that reason.", action, this));
	      }
	    }
	    return _results;
	  };


	  /*
	  	 * Constructor function that sets up actions and events on the store
	   */

	  function Store() {
	    this._handleAction = __bind(this._handleAction, this);
	    dispatcher.register(this);
	    this._properties = Immutable.Map();
	    this.changed = new Signal;
	    if (typeof this.initialize === "function") {
	      this.initialize();
	    }
	    return this.getInterface();
	  }


	  /*
	  	 * Override this to change which methods are available to consumers.
	  	 * NOTE: Remember that nothing but the store itself should be able to change the data in the store.
	   */

	  Store.prototype.getInterface = function() {
	    if ((this.getProxyObject != null) && this.getProxyObject !== Store.prototype.getProxyObject) {
	      console.warn("Store.getProxyObject() is deprecated use Store.getInterface()");
	    }
	    return {
	      get: this.get.bind(this),
	      getIn: this.getIn.bind(this),
	      changed: this.changed,
	      _id: this._id
	    };
	  };

	  Store.prototype.getProxyObject = function() {
	    return this.getInterface();
	  };

	  Store.prototype.getIn = function() {
	    var _ref;
	    return (_ref = this._properties).getIn.apply(_ref, arguments);
	  };

	  Store.prototype.get = function(name) {
	    var val;
	    val = null;
	    if (name != null) {
	      invariant(_.isString(name) || _.isArray(name), "Store.get(...): first parameter should be undefined, a string, or an array of keys.");
	      if (_.isArray(name)) {
	        val = this._properties.filter(function(val, key) {
	          return __indexOf.call(name, key) >= 0;
	        });
	      } else if (_.isString(name)) {
	        val = this._properties.get(name);
	      }
	    } else {
	      val = this._properties;
	    }
	    return val;
	  };

	  Store.prototype.set = function(name, val) {
	    var value;
	    invariant(_.isObject(name) || _.isString(name) && (val != null), "Store.set(...): You can only set an object or pass a string and a value.\nUse Store.unset(" + name + ") to unset the property.");
	    if (_.isString(name)) {
	      if (Immutable.Iterable.isIterable(val)) {
	        value = val;
	      } else {
	        value = Immutable.fromJS(val);
	      }
	      this._properties = this._properties.set(name, Immutable.fromJS(value));
	    }
	    if (_.isObject(name)) {
	      if (Immutable.Iterable.isIterable(name)) {
	        value = name;
	      } else {
	        value = Immutable.fromJS(name);
	      }
	      this._properties = Immutable.fromJS(name);
	    }
	    return this;
	  };

	  Store.prototype.merge = function(name, val) {
	    if (_.isString(name)) {
	      this._properties = this._properties.mergeDeep(val);
	    }
	    if (_.isObject(name)) {
	      this._properties = this._properties.mergeDeep(name);
	    }
	    return this;
	  };

	  Store.prototype.unset = function(name) {
	    invariant(_.isString(name), "Store.unset(...): first parameter must be a string.");
	    if (this._properties[name] != null) {
	      delete (this._properties = this._properties.remove(name));
	    }
	    return this;
	  };

	  Store.prototype.getCurrentActionID = function() {
	    invariant(this._currentActionInstance != null, "Action id is only available inside an action handler, in the current event loop iteration.\nIf you need to, you can call this function before you do any asynchronous work.");
	    return this._currentActionInstance.actionID;
	  };


	  /*
	  	 * Method for calling handlers on the store when an action is executed.
	  	 *
	  	 * @param {string} actionName The name of the executed action
	  	 * @param {mixed} payload The payload passed to the handler
	  	 * @param {array} waitFor An array of other signals to wait for in this dispatcher run.
	   */

	  Store.prototype._handleAction = function(actionInstance, waitFor) {
	    var _ref;
	    if (((_ref = this.constructor._handlers) != null ? _ref[actionInstance.type] : void 0) == null) {
	      return;
	    }
	    this._currentActionInstance = actionInstance;
	    this.constructor._handlers[actionInstance.type].call(this, actionInstance.payload, waitFor);
	    return this._currentActionInstance = null;
	  };

	  return Store;

	})();


/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	var InvariantError;

	InvariantError = __webpack_require__(10);


	/*
	 * Use invariant() to assert state which your program assumes to be true.
	 *
	 * Provided arguments are automatically type checked and logged correctly to the console
	 * Chrome's console.log sprintf format.
	 *
	 * ex: invariant(!hasFired, "hasFired was expected to be true but was", hasFired)
	 *
	 * The invariant message will be stripped in production, but the invariant
	 * will remain to ensure logic does not differ in production.
	 */

	module.exports = function(condition, message) {
	  var error;
	  if (!condition) {
	    if (message == null) {
	      error = new InvariantError("Minified exception occurred; use the non-minified dev environment\nfor the full error message and additional helpful warnings.");
	    } else {
	      error = new InvariantError(message);
	    }
	    error.framesToPop = 1;
	    throw error;
	  }
	};


/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_6__;

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_7__;

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	var Dispatcher, Signal, invariant,
	  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
	  __slice = [].slice;

	invariant = __webpack_require__(5);

	Signal = __webpack_require__(11).Signal;

	'use strict';

	module.exports = new (Dispatcher = (function() {

	  /*
	  	 * @var {boolean} dispatching Wether or not the dispatcher is currently dispatching.
	  	 * @private
	   */
	  var currentAction, dispatching, finalizeDispatching, isHandled, isPending, notifyStore, prepareForDispatching, storeID, stores;

	  function Dispatcher() {
	    this.dispatch = __bind(this.dispatch, this);
	    this.waitFor = __bind(this.waitFor, this);
	  }

	  dispatching = false;


	  /*
	  	 * @var {integer} storeID ID to use for the next store that gets registered.
	  	 * @private
	   */

	  storeID = 0;


	  /*
	  	 * @var {object} stores Store registry.
	  	 * @private
	   */

	  stores = {};


	  /*
	      * @var {object} isPending Object for tracking pending store callbacks.
	  	 * @private
	   */

	  isPending = {};


	  /*
	      * @var {object} isPending Object for tracking handled store callbacks.
	  	 * @private
	   */

	  isHandled = {};


	  /*
	      * @var {string} isPending The current action being dispatched, if any.
	  	 * @private
	   */

	  currentAction = null;


	  /*
	      * @var {object} Signal triggered when the dispatcher is started.
	  	 * @public
	   */

	  Dispatcher.prototype.started = new Signal();


	  /*
	      * @var {object} Signal triggered when the dispatcher is stopped.
	  	 * @public
	   */

	  Dispatcher.prototype.stopped = new Signal();


	  /*
	      * Sets the dispatcher to a state where all stores are neither
	      * pending nor handled.
	      *
	  	 * @private
	   */

	  prepareForDispatching = function() {
	    var id;
	    dispatching = true;
	    for (id in stores) {
	      isPending[id] = false;
	      isHandled[id] = false;
	    }
	    return this.started.dispatch();
	  };


	  /*
	      * Resets the dispatcher state after dispatching.
	      *
	  	 * @private
	   */

	  finalizeDispatching = function() {
	    currentAction = null;
	    dispatching = false;
	    return this.stopped.dispatch();
	  };


	  /*
	      * Calls the action handler on a store with the current action and payload.
	      * This method is used when dispatching.
	      *
	      * @param {integer} id The ID of the store to notify
	  	 * @private
	   */

	  notifyStore = function(id) {
	    invariant(currentAction != null, "Cannot notify store without an action");
	    isPending[id] = true;
	    stores[id]._handleAction.call(stores[id], currentAction, this.waitFor);
	    return isHandled[id] = true;
	  };


	  /*
	      * Registers a store with the dispatcher so that it's notified when actions
	      * are dispatched.
	      *
	      * @param {Object} store The store to register with the dispatcher
	   */

	  Dispatcher.prototype.register = function(store) {
	    stores[storeID] = store;
	    return store._id = storeID++;
	  };


	  /*
	      * Unregisters a store from the dispatcher so that it's no longer
	      * notified when actions are dispatched.
	      *
	      * @param {Object} store The store to unregister from the dispatcher
	   */

	  Dispatcher.prototype.unregister = function(store) {
	    invariant((store._id != null) && (stores[store._id] != null), "dispatcher.unregister(...): Store is not registered with the dispatcher.");
	    return delete stores[store._id];
	  };


	  /*
	      * Method for waiting for other stores to complete their handling
	      * of actions. This method is passed along to the Stores when an action
	      * is dispatched.
	      *
	      * @see notifyStore
	   */

	  Dispatcher.prototype.waitFor = function() {
	    var dependency, id, storeDependencies, _i, _len, _results;
	    storeDependencies = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
	    invariant(dispatching, "dispatcher.waitFor(): It's not possible to wait for dependencies when the dispatcher isn't dispatching.\nwaitFor() should be called in an action handler.");
	    _results = [];
	    for (_i = 0, _len = storeDependencies.length; _i < _len; _i++) {
	      dependency = storeDependencies[_i];
	      id = dependency._id;
	      invariant((id != null) && (stores[id] != null), 'dispatcher.waitFor(...): dependency is not registered with the dispatcher.');
	      if (isPending[id]) {
	        invariant(isHandled[id], 'dispatcher.waitFor(...): Circular dependency detected.');
	        continue;
	      }
	      _results.push(notifyStore.call(this, id));
	    }
	    return _results;
	  };


	  /*
	      * Method for dispatching in action. This method is used by the Action class
	      * when calling Action.dispatch().
	      *
	      * @param {string} actionName The name of the action to dispatch
	      * @param {mixed} payload The payload for the event.
	   */

	  Dispatcher.prototype.dispatch = function(actionInstance) {
	    var id, _results;
	    invariant(!dispatching, 'dispatcher.dispatch(...): Cannot dispatch in the middle of a dispatch.');
	    currentAction = actionInstance;
	    prepareForDispatching.call(this);
	    try {
	      _results = [];
	      for (id in stores) {
	        if (isPending[id]) {
	          continue;
	        }
	        _results.push(notifyStore.call(this, id));
	      }
	      return _results;
	    } finally {
	      finalizeDispatching.call(this);
	    }
	  };

	  return Dispatcher;

	})());


/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	var Action, dispatcher;

	dispatcher = __webpack_require__(8);

	Action = (function() {

	  /*
	  	 * Constructor
	  	 *
	  	 * @param {string} The name of the action
	   */
	  function Action(type) {
	    this.type = type;
	  }


	  /*
	  	 * Magic method for coercing an action to a string
	   */

	  Action.prototype.toString = function() {
	    return this.type;
	  };

	  return Action;

	})();

	module.exports = Action;


/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	var InvariantError,
	  __hasProp = {}.hasOwnProperty,
	  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

	module.exports = InvariantError = (function(_super) {
	  __extends(InvariantError, _super);

	  function InvariantError(message) {
	    this.name = "Invariant Error";
	    this.message = message;
	  }

	  return InvariantError;

	})(Error);


/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	var __WEBPACK_AMD_DEFINE_RESULT__;/*jslint onevar:true, undef:true, newcap:true, regexp:true, bitwise:true, maxerr:50, indent:4, white:false, nomen:false, plusplus:false */
	/*global define:false, require:false, exports:false, module:false, signals:false */

	/** @license
	 * JS Signals <http://millermedeiros.github.com/js-signals/>
	 * Released under the MIT license
	 * Author: Miller Medeiros
	 * Version: 1.0.0 - Build: 268 (2012/11/29 05:48 PM)
	 */

	(function(global){

	    // SignalBinding -------------------------------------------------
	    //================================================================

	    /**
	     * Object that represents a binding between a Signal and a listener function.
	     * <br />- <strong>This is an internal constructor and shouldn't be called by regular users.</strong>
	     * <br />- inspired by Joa Ebert AS3 SignalBinding and Robert Penner's Slot classes.
	     * @author Miller Medeiros
	     * @constructor
	     * @internal
	     * @name SignalBinding
	     * @param {Signal} signal Reference to Signal object that listener is currently bound to.
	     * @param {Function} listener Handler function bound to the signal.
	     * @param {boolean} isOnce If binding should be executed just once.
	     * @param {Object} [listenerContext] Context on which listener will be executed (object that should represent the `this` variable inside listener function).
	     * @param {Number} [priority] The priority level of the event listener. (default = 0).
	     */
	    function SignalBinding(signal, listener, isOnce, listenerContext, priority) {

	        /**
	         * Handler function bound to the signal.
	         * @type Function
	         * @private
	         */
	        this._listener = listener;

	        /**
	         * If binding should be executed just once.
	         * @type boolean
	         * @private
	         */
	        this._isOnce = isOnce;

	        /**
	         * Context on which listener will be executed (object that should represent the `this` variable inside listener function).
	         * @memberOf SignalBinding.prototype
	         * @name context
	         * @type Object|undefined|null
	         */
	        this.context = listenerContext;

	        /**
	         * Reference to Signal object that listener is currently bound to.
	         * @type Signal
	         * @private
	         */
	        this._signal = signal;

	        /**
	         * Listener priority
	         * @type Number
	         * @private
	         */
	        this._priority = priority || 0;
	    }

	    SignalBinding.prototype = {

	        /**
	         * If binding is active and should be executed.
	         * @type boolean
	         */
	        active : true,

	        /**
	         * Default parameters passed to listener during `Signal.dispatch` and `SignalBinding.execute`. (curried parameters)
	         * @type Array|null
	         */
	        params : null,

	        /**
	         * Call listener passing arbitrary parameters.
	         * <p>If binding was added using `Signal.addOnce()` it will be automatically removed from signal dispatch queue, this method is used internally for the signal dispatch.</p>
	         * @param {Array} [paramsArr] Array of parameters that should be passed to the listener
	         * @return {*} Value returned by the listener.
	         */
	        execute : function (paramsArr) {
	            var handlerReturn, params;
	            if (this.active && !!this._listener) {
	                params = this.params? this.params.concat(paramsArr) : paramsArr;
	                handlerReturn = this._listener.apply(this.context, params);
	                if (this._isOnce) {
	                    this.detach();
	                }
	            }
	            return handlerReturn;
	        },

	        /**
	         * Detach binding from signal.
	         * - alias to: mySignal.remove(myBinding.getListener());
	         * @return {Function|null} Handler function bound to the signal or `null` if binding was previously detached.
	         */
	        detach : function () {
	            return this.isBound()? this._signal.remove(this._listener, this.context) : null;
	        },

	        /**
	         * @return {Boolean} `true` if binding is still bound to the signal and have a listener.
	         */
	        isBound : function () {
	            return (!!this._signal && !!this._listener);
	        },

	        /**
	         * @return {boolean} If SignalBinding will only be executed once.
	         */
	        isOnce : function () {
	            return this._isOnce;
	        },

	        /**
	         * @return {Function} Handler function bound to the signal.
	         */
	        getListener : function () {
	            return this._listener;
	        },

	        /**
	         * @return {Signal} Signal that listener is currently bound to.
	         */
	        getSignal : function () {
	            return this._signal;
	        },

	        /**
	         * Delete instance properties
	         * @private
	         */
	        _destroy : function () {
	            delete this._signal;
	            delete this._listener;
	            delete this.context;
	        },

	        /**
	         * @return {string} String representation of the object.
	         */
	        toString : function () {
	            return '[SignalBinding isOnce:' + this._isOnce +', isBound:'+ this.isBound() +', active:' + this.active + ']';
	        }

	    };


	/*global SignalBinding:false*/

	    // Signal --------------------------------------------------------
	    //================================================================

	    function validateListener(listener, fnName) {
	        if (typeof listener !== 'function') {
	            throw new Error( 'listener is a required param of {fn}() and should be a Function.'.replace('{fn}', fnName) );
	        }
	    }

	    /**
	     * Custom event broadcaster
	     * <br />- inspired by Robert Penner's AS3 Signals.
	     * @name Signal
	     * @author Miller Medeiros
	     * @constructor
	     */
	    function Signal() {
	        /**
	         * @type Array.<SignalBinding>
	         * @private
	         */
	        this._bindings = [];
	        this._prevParams = null;

	        // enforce dispatch to aways work on same context (#47)
	        var self = this;
	        this.dispatch = function(){
	            Signal.prototype.dispatch.apply(self, arguments);
	        };
	    }

	    Signal.prototype = {

	        /**
	         * Signals Version Number
	         * @type String
	         * @const
	         */
	        VERSION : '1.0.0',

	        /**
	         * If Signal should keep record of previously dispatched parameters and
	         * automatically execute listener during `add()`/`addOnce()` if Signal was
	         * already dispatched before.
	         * @type boolean
	         */
	        memorize : false,

	        /**
	         * @type boolean
	         * @private
	         */
	        _shouldPropagate : true,

	        /**
	         * If Signal is active and should broadcast events.
	         * <p><strong>IMPORTANT:</strong> Setting this property during a dispatch will only affect the next dispatch, if you want to stop the propagation of a signal use `halt()` instead.</p>
	         * @type boolean
	         */
	        active : true,

	        /**
	         * @param {Function} listener
	         * @param {boolean} isOnce
	         * @param {Object} [listenerContext]
	         * @param {Number} [priority]
	         * @return {SignalBinding}
	         * @private
	         */
	        _registerListener : function (listener, isOnce, listenerContext, priority) {

	            var prevIndex = this._indexOfListener(listener, listenerContext),
	                binding;

	            if (prevIndex !== -1) {
	                binding = this._bindings[prevIndex];
	                if (binding.isOnce() !== isOnce) {
	                    throw new Error('You cannot add'+ (isOnce? '' : 'Once') +'() then add'+ (!isOnce? '' : 'Once') +'() the same listener without removing the relationship first.');
	                }
	            } else {
	                binding = new SignalBinding(this, listener, isOnce, listenerContext, priority);
	                this._addBinding(binding);
	            }

	            if(this.memorize && this._prevParams){
	                binding.execute(this._prevParams);
	            }

	            return binding;
	        },

	        /**
	         * @param {SignalBinding} binding
	         * @private
	         */
	        _addBinding : function (binding) {
	            //simplified insertion sort
	            var n = this._bindings.length;
	            do { --n; } while (this._bindings[n] && binding._priority <= this._bindings[n]._priority);
	            this._bindings.splice(n + 1, 0, binding);
	        },

	        /**
	         * @param {Function} listener
	         * @return {number}
	         * @private
	         */
	        _indexOfListener : function (listener, context) {
	            var n = this._bindings.length,
	                cur;
	            while (n--) {
	                cur = this._bindings[n];
	                if (cur._listener === listener && cur.context === context) {
	                    return n;
	                }
	            }
	            return -1;
	        },

	        /**
	         * Check if listener was attached to Signal.
	         * @param {Function} listener
	         * @param {Object} [context]
	         * @return {boolean} if Signal has the specified listener.
	         */
	        has : function (listener, context) {
	            return this._indexOfListener(listener, context) !== -1;
	        },

	        /**
	         * Add a listener to the signal.
	         * @param {Function} listener Signal handler function.
	         * @param {Object} [listenerContext] Context on which listener will be executed (object that should represent the `this` variable inside listener function).
	         * @param {Number} [priority] The priority level of the event listener. Listeners with higher priority will be executed before listeners with lower priority. Listeners with same priority level will be executed at the same order as they were added. (default = 0)
	         * @return {SignalBinding} An Object representing the binding between the Signal and listener.
	         */
	        add : function (listener, listenerContext, priority) {
	            validateListener(listener, 'add');
	            return this._registerListener(listener, false, listenerContext, priority);
	        },

	        /**
	         * Add listener to the signal that should be removed after first execution (will be executed only once).
	         * @param {Function} listener Signal handler function.
	         * @param {Object} [listenerContext] Context on which listener will be executed (object that should represent the `this` variable inside listener function).
	         * @param {Number} [priority] The priority level of the event listener. Listeners with higher priority will be executed before listeners with lower priority. Listeners with same priority level will be executed at the same order as they were added. (default = 0)
	         * @return {SignalBinding} An Object representing the binding between the Signal and listener.
	         */
	        addOnce : function (listener, listenerContext, priority) {
	            validateListener(listener, 'addOnce');
	            return this._registerListener(listener, true, listenerContext, priority);
	        },

	        /**
	         * Remove a single listener from the dispatch queue.
	         * @param {Function} listener Handler function that should be removed.
	         * @param {Object} [context] Execution context (since you can add the same handler multiple times if executing in a different context).
	         * @return {Function} Listener handler function.
	         */
	        remove : function (listener, context) {
	            validateListener(listener, 'remove');

	            var i = this._indexOfListener(listener, context);
	            if (i !== -1) {
	                this._bindings[i]._destroy(); //no reason to a SignalBinding exist if it isn't attached to a signal
	                this._bindings.splice(i, 1);
	            }
	            return listener;
	        },

	        /**
	         * Remove all listeners from the Signal.
	         */
	        removeAll : function () {
	            var n = this._bindings.length;
	            while (n--) {
	                this._bindings[n]._destroy();
	            }
	            this._bindings.length = 0;
	        },

	        /**
	         * @return {number} Number of listeners attached to the Signal.
	         */
	        getNumListeners : function () {
	            return this._bindings.length;
	        },

	        /**
	         * Stop propagation of the event, blocking the dispatch to next listeners on the queue.
	         * <p><strong>IMPORTANT:</strong> should be called only during signal dispatch, calling it before/after dispatch won't affect signal broadcast.</p>
	         * @see Signal.prototype.disable
	         */
	        halt : function () {
	            this._shouldPropagate = false;
	        },

	        /**
	         * Dispatch/Broadcast Signal to all listeners added to the queue.
	         * @param {...*} [params] Parameters that should be passed to each handler.
	         */
	        dispatch : function (params) {
	            if (! this.active) {
	                return;
	            }

	            var paramsArr = Array.prototype.slice.call(arguments),
	                n = this._bindings.length,
	                bindings;

	            if (this.memorize) {
	                this._prevParams = paramsArr;
	            }

	            if (! n) {
	                //should come after memorize
	                return;
	            }

	            bindings = this._bindings.slice(); //clone array in case add/remove items during dispatch
	            this._shouldPropagate = true; //in case `halt` was called before dispatch or during the previous dispatch.

	            //execute all callbacks until end of the list or until a callback returns `false` or stops propagation
	            //reverse loop since listeners with higher priority will be added at the end of the list
	            do { n--; } while (bindings[n] && this._shouldPropagate && bindings[n].execute(paramsArr) !== false);
	        },

	        /**
	         * Forget memorized arguments.
	         * @see Signal.memorize
	         */
	        forget : function(){
	            this._prevParams = null;
	        },

	        /**
	         * Remove all bindings from signal and destroy any reference to external objects (destroy Signal object).
	         * <p><strong>IMPORTANT:</strong> calling any method on the signal instance after calling dispose will throw errors.</p>
	         */
	        dispose : function () {
	            this.removeAll();
	            delete this._bindings;
	            delete this._prevParams;
	        },

	        /**
	         * @return {string} String representation of the object.
	         */
	        toString : function () {
	            return '[Signal active:'+ this.active +' numListeners:'+ this.getNumListeners() +']';
	        }

	    };


	    // Namespace -----------------------------------------------------
	    //================================================================

	    /**
	     * Signals namespace
	     * @namespace
	     * @name signals
	     */
	    var signals = Signal;

	    /**
	     * Custom event broadcaster
	     * @see Signal
	     */
	    // alias for backwards compatibility (see #gh-44)
	    signals.Signal = Signal;



	    //exports to multiple environments
	    if(true){ //AMD
	        !(__WEBPACK_AMD_DEFINE_RESULT__ = function () { return signals; }.call(exports, __webpack_require__, exports, module), __WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
	    } else if (typeof module !== 'undefined' && module.exports){ //node
	        module.exports = signals;
	    } else { //browser
	        //use string because of Google closure compiler ADVANCED_MODE
	        /*jslint sub:true */
	        global['signals'] = signals;
	    }

	}(this));


/***/ }
/******/ ])
});
;