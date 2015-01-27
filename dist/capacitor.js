/**
 * @license capacitor.js 0.0.20 Copyright (c) 2014, Mikkel Schmidt. All Rights Reserved.
 * Available via the MIT license.
 */

(function (root, factory) {
	if (typeof define === 'function' && define.amd) {
		// AMD.
		define(['lodash'], factory);
	} else if (typeof module !== 'undefined' && module.exports) {
		// CommonJS
		var _ = require('lodash');
		module.exports = factory(_);
	} else {
		// Browser globals.
		root.capacitor = factory(root._);
	}
}(this, function(_) {

/**
 * @license almond 0.3.0 Copyright (c) 2011-2014, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/almond for details
 */
//Going sloppy to avoid 'use strict' string cost, but strict practices should
//be followed.
/*jslint sloppy: true */
/*global setTimeout: false */

var requirejs, require, define;
(function (undef) {
    var main, req, makeMap, handlers,
        defined = {},
        waiting = {},
        config = {},
        defining = {},
        hasOwn = Object.prototype.hasOwnProperty,
        aps = [].slice,
        jsSuffixRegExp = /\.js$/;

    function hasProp(obj, prop) {
        return hasOwn.call(obj, prop);
    }

    /**
     * Given a relative module name, like ./something, normalize it to
     * a real name that can be mapped to a path.
     * @param {String} name the relative name
     * @param {String} baseName a real name that the name arg is relative
     * to.
     * @returns {String} normalized name
     */
    function normalize(name, baseName) {
        var nameParts, nameSegment, mapValue, foundMap, lastIndex,
            foundI, foundStarMap, starI, i, j, part,
            baseParts = baseName && baseName.split("/"),
            map = config.map,
            starMap = (map && map['*']) || {};

        //Adjust any relative paths.
        if (name && name.charAt(0) === ".") {
            //If have a base name, try to normalize against it,
            //otherwise, assume it is a top-level require that will
            //be relative to baseUrl in the end.
            if (baseName) {
                //Convert baseName to array, and lop off the last part,
                //so that . matches that "directory" and not name of the baseName's
                //module. For instance, baseName of "one/two/three", maps to
                //"one/two/three.js", but we want the directory, "one/two" for
                //this normalization.
                baseParts = baseParts.slice(0, baseParts.length - 1);
                name = name.split('/');
                lastIndex = name.length - 1;

                // Node .js allowance:
                if (config.nodeIdCompat && jsSuffixRegExp.test(name[lastIndex])) {
                    name[lastIndex] = name[lastIndex].replace(jsSuffixRegExp, '');
                }

                name = baseParts.concat(name);

                //start trimDots
                for (i = 0; i < name.length; i += 1) {
                    part = name[i];
                    if (part === ".") {
                        name.splice(i, 1);
                        i -= 1;
                    } else if (part === "..") {
                        if (i === 1 && (name[2] === '..' || name[0] === '..')) {
                            //End of the line. Keep at least one non-dot
                            //path segment at the front so it can be mapped
                            //correctly to disk. Otherwise, there is likely
                            //no path mapping for a path starting with '..'.
                            //This can still fail, but catches the most reasonable
                            //uses of ..
                            break;
                        } else if (i > 0) {
                            name.splice(i - 1, 2);
                            i -= 2;
                        }
                    }
                }
                //end trimDots

                name = name.join("/");
            } else if (name.indexOf('./') === 0) {
                // No baseName, so this is ID is resolved relative
                // to baseUrl, pull off the leading dot.
                name = name.substring(2);
            }
        }

        //Apply map config if available.
        if ((baseParts || starMap) && map) {
            nameParts = name.split('/');

            for (i = nameParts.length; i > 0; i -= 1) {
                nameSegment = nameParts.slice(0, i).join("/");

                if (baseParts) {
                    //Find the longest baseName segment match in the config.
                    //So, do joins on the biggest to smallest lengths of baseParts.
                    for (j = baseParts.length; j > 0; j -= 1) {
                        mapValue = map[baseParts.slice(0, j).join('/')];

                        //baseName segment has  config, find if it has one for
                        //this name.
                        if (mapValue) {
                            mapValue = mapValue[nameSegment];
                            if (mapValue) {
                                //Match, update name to the new value.
                                foundMap = mapValue;
                                foundI = i;
                                break;
                            }
                        }
                    }
                }

                if (foundMap) {
                    break;
                }

                //Check for a star map match, but just hold on to it,
                //if there is a shorter segment match later in a matching
                //config, then favor over this star map.
                if (!foundStarMap && starMap && starMap[nameSegment]) {
                    foundStarMap = starMap[nameSegment];
                    starI = i;
                }
            }

            if (!foundMap && foundStarMap) {
                foundMap = foundStarMap;
                foundI = starI;
            }

            if (foundMap) {
                nameParts.splice(0, foundI, foundMap);
                name = nameParts.join('/');
            }
        }

        return name;
    }

    function makeRequire(relName, forceSync) {
        return function () {
            //A version of a require function that passes a moduleName
            //value for items that may need to
            //look up paths relative to the moduleName
            var args = aps.call(arguments, 0);

            //If first arg is not require('string'), and there is only
            //one arg, it is the array form without a callback. Insert
            //a null so that the following concat is correct.
            if (typeof args[0] !== 'string' && args.length === 1) {
                args.push(null);
            }
            return req.apply(undef, args.concat([relName, forceSync]));
        };
    }

    function makeNormalize(relName) {
        return function (name) {
            return normalize(name, relName);
        };
    }

    function makeLoad(depName) {
        return function (value) {
            defined[depName] = value;
        };
    }

    function callDep(name) {
        if (hasProp(waiting, name)) {
            var args = waiting[name];
            delete waiting[name];
            defining[name] = true;
            main.apply(undef, args);
        }

        if (!hasProp(defined, name) && !hasProp(defining, name)) {
            throw new Error('No ' + name);
        }
        return defined[name];
    }

    //Turns a plugin!resource to [plugin, resource]
    //with the plugin being undefined if the name
    //did not have a plugin prefix.
    function splitPrefix(name) {
        var prefix,
            index = name ? name.indexOf('!') : -1;
        if (index > -1) {
            prefix = name.substring(0, index);
            name = name.substring(index + 1, name.length);
        }
        return [prefix, name];
    }

    /**
     * Makes a name map, normalizing the name, and using a plugin
     * for normalization if necessary. Grabs a ref to plugin
     * too, as an optimization.
     */
    makeMap = function (name, relName) {
        var plugin,
            parts = splitPrefix(name),
            prefix = parts[0];

        name = parts[1];

        if (prefix) {
            prefix = normalize(prefix, relName);
            plugin = callDep(prefix);
        }

        //Normalize according
        if (prefix) {
            if (plugin && plugin.normalize) {
                name = plugin.normalize(name, makeNormalize(relName));
            } else {
                name = normalize(name, relName);
            }
        } else {
            name = normalize(name, relName);
            parts = splitPrefix(name);
            prefix = parts[0];
            name = parts[1];
            if (prefix) {
                plugin = callDep(prefix);
            }
        }

        //Using ridiculous property names for space reasons
        return {
            f: prefix ? prefix + '!' + name : name, //fullName
            n: name,
            pr: prefix,
            p: plugin
        };
    };

    function makeConfig(name) {
        return function () {
            return (config && config.config && config.config[name]) || {};
        };
    }

    handlers = {
        require: function (name) {
            return makeRequire(name);
        },
        exports: function (name) {
            var e = defined[name];
            if (typeof e !== 'undefined') {
                return e;
            } else {
                return (defined[name] = {});
            }
        },
        module: function (name) {
            return {
                id: name,
                uri: '',
                exports: defined[name],
                config: makeConfig(name)
            };
        }
    };

    main = function (name, deps, callback, relName) {
        var cjsModule, depName, ret, map, i,
            args = [],
            callbackType = typeof callback,
            usingExports;

        //Use name if no relName
        relName = relName || name;

        //Call the callback to define the module, if necessary.
        if (callbackType === 'undefined' || callbackType === 'function') {
            //Pull out the defined dependencies and pass the ordered
            //values to the callback.
            //Default to [require, exports, module] if no deps
            deps = !deps.length && callback.length ? ['require', 'exports', 'module'] : deps;
            for (i = 0; i < deps.length; i += 1) {
                map = makeMap(deps[i], relName);
                depName = map.f;

                //Fast path CommonJS standard dependencies.
                if (depName === "require") {
                    args[i] = handlers.require(name);
                } else if (depName === "exports") {
                    //CommonJS module spec 1.1
                    args[i] = handlers.exports(name);
                    usingExports = true;
                } else if (depName === "module") {
                    //CommonJS module spec 1.1
                    cjsModule = args[i] = handlers.module(name);
                } else if (hasProp(defined, depName) ||
                           hasProp(waiting, depName) ||
                           hasProp(defining, depName)) {
                    args[i] = callDep(depName);
                } else if (map.p) {
                    map.p.load(map.n, makeRequire(relName, true), makeLoad(depName), {});
                    args[i] = defined[depName];
                } else {
                    throw new Error(name + ' missing ' + depName);
                }
            }

            ret = callback ? callback.apply(defined[name], args) : undefined;

            if (name) {
                //If setting exports via "module" is in play,
                //favor that over return value and exports. After that,
                //favor a non-undefined return value over exports use.
                if (cjsModule && cjsModule.exports !== undef &&
                        cjsModule.exports !== defined[name]) {
                    defined[name] = cjsModule.exports;
                } else if (ret !== undef || !usingExports) {
                    //Use the return value from the function.
                    defined[name] = ret;
                }
            }
        } else if (name) {
            //May just be an object definition for the module. Only
            //worry about defining if have a module name.
            defined[name] = callback;
        }
    };

    requirejs = require = req = function (deps, callback, relName, forceSync, alt) {
        if (typeof deps === "string") {
            if (handlers[deps]) {
                //callback in this case is really relName
                return handlers[deps](callback);
            }
            //Just return the module wanted. In this scenario, the
            //deps arg is the module name, and second arg (if passed)
            //is just the relName.
            //Normalize module name, if it contains . or ..
            return callDep(makeMap(deps, callback).f);
        } else if (!deps.splice) {
            //deps is a config object, not an array.
            config = deps;
            if (config.deps) {
                req(config.deps, config.callback);
            }
            if (!callback) {
                return;
            }

            if (callback.splice) {
                //callback is an array, which means it is a dependency list.
                //Adjust args if there are dependencies
                deps = callback;
                callback = relName;
                relName = null;
            } else {
                deps = undef;
            }
        }

        //Support require(['a'])
        callback = callback || function () {};

        //If relName is a function, it is an errback handler,
        //so remove it.
        if (typeof relName === 'function') {
            relName = forceSync;
            forceSync = alt;
        }

        //Simulate async callback;
        if (forceSync) {
            main(undef, deps, callback, relName);
        } else {
            //Using a non-zero value because of concern for what old browsers
            //do, and latest browsers "upgrade" to 4 if lower value is used:
            //http://www.whatwg.org/specs/web-apps/current-work/multipage/timers.html#dom-windowtimers-settimeout:
            //If want a value immediately, use require('id') instead -- something
            //that works in almond on the global level, but not guaranteed and
            //unlikely to work in other AMD implementations.
            setTimeout(function () {
                main(undef, deps, callback, relName);
            }, 4);
        }

        return req;
    };

    /**
     * Just drops the config on the floor, but returns req in case
     * the config return value is used.
     */
    req.config = function (cfg) {
        return req(cfg);
    };

    /**
     * Expose module registry for debugging and tooling
     */
    requirejs._defined = defined;

    define = function (name, deps, callback) {

        //This module may not have dependencies
        if (!deps.splice) {
            //deps is not an array, so probably means
            //an object literal or factory function for
            //the value. Adjust args.
            callback = deps;
            deps = [];
        }

        if (!hasProp(defined, name) && !hasProp(waiting, name)) {
            waiting[name] = [name, deps, callback];
        }
    };

    define.amd = {
        jQuery: true
    };
}());
define("../vendor/almond", function(){});

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define('invariant-error',[],function() {
    var InvariantError;
    return InvariantError = (function(_super) {
      __extends(InvariantError, _super);

      function InvariantError(message) {
        this.name = "Invariant Error";
        this.message = message;
      }

      return InvariantError;

    })(Error);
  });

}).call(this);

(function() {
  define('invariant',['invariant-error'], function(InvariantError) {

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
    return function(condition, message) {
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
  });

}).call(this);

/*jslint onevar:true, undef:true, newcap:true, regexp:true, bitwise:true, maxerr:50, indent:4, white:false, nomen:false, plusplus:false */
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
    if(typeof define === 'function' && define.amd){ //AMD
        define('signals',[],function () { return signals; });
    } else if (typeof module !== 'undefined' && module.exports){ //node
        module.exports = signals;
    } else { //browser
        //use string because of Google closure compiler ADVANCED_MODE
        /*jslint sub:true */
        global['signals'] = signals;
    }

}(this));

(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice;

  define('dispatcher',['invariant', 'signals'], function(invariant, _arg) {
    var Dispatcher, Signal;
    Signal = _arg.Signal;
    
    Dispatcher = (function() {

      /*
       * @var {boolean} dispatching Wether or not the dispatcher is currently dispatching.
       * @private
       */
      var currentAction, currentPayload, dispatching, finalizeDispatching, isHandled, isPending, notifyStore, prepareForDispatching, storeID, stores;

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
           * @var {mixed} isPending The current payload being dispatched, if any.
       * @private
       */

      currentPayload = null;


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
        currentPayload = null;
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
        var args;
        invariant(currentAction != null, "Cannot notify store without an action");
        isPending[id] = true;
        args = [currentAction];
        if (currentPayload != null) {
          args.push(currentPayload);
        }
        args.push(this.waitFor);
        stores[id]._handleAction.apply(stores[id], args);
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

      Dispatcher.prototype.dispatch = function(actionName, payload) {
        var id, _results;
        invariant(!dispatching, 'dispatcher.dispatch(...): Cannot dispatch in the middle of a dispatch.');
        currentAction = actionName;
        if (payload != null) {
          currentPayload = payload;
        }
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

    })();
    return new Dispatcher();
  });

}).call(this);

(function() {
  define('action',['dispatcher'], function(dispatcher) {
    var Action;
    return Action = (function() {

      /*
       * Constructor
       * 
       * @param {string} The name of the action
       */
      function Action(name) {
        this.name = name;
      }


      /*
       * Method for dispatching the action through the dispatcher
       *
       * @param {mixed} Payload for the action
       */

      Action.prototype.dispatch = function(payload) {
        return dispatcher.dispatch(this.name, payload);
      };


      /*
       * Magic method for coercing an action to a string
       */

      Action.prototype.toString = function() {
        return this.name;
      };

      return Action;

    })();
  });

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty;

  define('action-manager',['invariant', 'dispatcher', 'action'], function(invariant, dispatcher, Action) {
    var ActionManager;
    ActionManager = (function() {

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

    })();
    return new ActionManager;
  });

}).call(this);

(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty;

  define('store',['lodash', 'signals', 'action', 'dispatcher', 'invariant'], function(_, _arg, Action, dispatcher, invariant) {
    var Signal, Store;
    Signal = _arg.Signal;

    /*
     *  implementation example:
     *
     *  class TodoStore extends Store
     *    @action someAction, () ->
     *      @doStuff()
     *      @doOtherStuff()
     *      @profit()
     *
     *    doStuff: () ->
     *      # Do things..
     *
     *
     *    doOtherStuff: () ->
     *      # Do things..
     *
     *    profit: () ->
     *      # Do things..
     *      @changed.dispatch()
     */
    return Store = (function() {

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
        this._properties = {};
        this.changed = new Signal;
        if (typeof this.initialize === "function") {
          this.initialize();
        }
        return this.getProxyObject();
      }


      /*
       * Override this to change which methods are available to consumers.
       * NOTE: Remember that nothing but the store itself should be able to change the data in the store.
       */

      Store.prototype.getProxyObject = function() {
        return {
          get: this.get.bind(this),
          changed: this.changed,
          _id: this._id
        };
      };

      Store.prototype.get = function(name) {
        var val;
        val = null;
        if (name != null) {
          invariant(_.isString(name) || _.isArray(name), "Store.get(...): first parameter should be undefined, a string, or an array of keys.");
          val = _.pick(this._properties, name);
          if (_.isString(name)) {
            val = val[name];
          }
          if (_.isObject(val)) {
            val = _.cloneDeep(val);
          }
        } else {
          val = _.cloneDeep(this._properties);
        }
        return val;
      };

      Store.prototype.set = function(name, val) {
        var newProps, properties;
        invariant(_.isObject(name) || _.isString(name) && (val != null), "Store.set(...): You can only set an object or pass a string and a value.\nUse Store.unset(" + name + ") to unset the property.");
        if (_.isString(name)) {
          properties = {};
          properties[name] = val;
        }
        if (_.isObject(name)) {
          properties = name;
        }
        newProps = _.cloneDeep(properties);
        _.assign(this._properties, newProps);
        this.changed.dispatch('set', newProps);
        return this;
      };

      Store.prototype.merge = function(name, val) {
        var changedProps, newProps, properties;
        if (_.isString(name)) {
          properties = {};
          properties[name] = val;
        }
        if (_.isObject(name)) {
          properties = name;
        }
        newProps = _.cloneDeep(properties);
        _.merge(this._properties, newProps);
        changedProps = _.pick(this._properties, _.keys(newProps));
        this.changed.dispatch('merge', changedProps);
        return this;
      };

      Store.prototype.unset = function(name) {
        invariant(_.isString(name), "Store.unset(...): first parameter must be a string.");
        if (this._properties[name] != null) {
          delete this._properties[name];
        }
        this.changed.dispatch('unset', name);
        return this;
      };


      /*
       * Method for calling handlers on the store when an action is executed.
       *
       * @param {string} actionName The name of the executed action
       * @param {mixed} payload The payload passed to the handler
       * @param {array} waitFor An array of other signals to wait for in this dispatcher run.
       */

      Store.prototype._handleAction = function(actionName, payload, waitFor) {
        var _ref;
        if (((_ref = this.constructor._handlers) != null ? _ref[actionName] : void 0) == null) {
          return;
        }
        return this.constructor._handlers[actionName].call(this, payload, waitFor);
      };

      return Store;

    })();
  });

}).call(this);

(function() {
  define('main',['dispatcher', 'action-manager', 'store', 'invariant', 'signals'], function(dispatcher, actionManager, Store, invariant, _arg) {
    var Signal;
    Signal = _arg.Signal;
    return {
      dispatcher: dispatcher,
      actionManager: actionManager,
      Store: Store,
      invariant: invariant,
      Signal: Signal
    };
  });

}).call(this);

	define('lodash', function() {
		return _;
	});
    return require('main');
}));
