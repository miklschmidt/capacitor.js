## Introduction
#### WARNING: Still being documented.
Capacitor.js is a well tested implementation of facebook's flux architecture written in CoffeeScript, which aims to do the following things:

* Be as close to the official definition of flux as possible, only making optimizations/features where there's too much boilerplate. 
* Be easy to use, even for beginners, which means it should be easy to do it right, hard to do it wrong.
  * An example is the ActionCreators, which is the only way to dispatch an action without going out of your way.
* Have all stores be comprised of immutable data with immutable.js
* Handle relationships between stores with ease, without the boilerplate
* Be easy to extend, where extensions make sense.
* Scale well when used in teams by heavily encouraging thought before code, and try to minize how many ways you can solve a single problem.
* Feel great to use in CoffeeScript
* Feel just as great to use in TypeScript/ES6
* Support all the loaders, AMD/CommonJS/ES6/Globals whatever you need.

## Features
* The dispatcher is an implementation detail, you never interact with it manually.
* Actions are class instances, no giant switch statements needed. 
* Stores listen for actions by using the action classes.
* Four types of stores to model your data:
  * Store (generic state)
  * EntityStore (anything with an id)
  * ListStore (a list of entities)
  * IndexedListStore (a map from an entity id to a list of entity ids)
* With these four stores you can model the following:
  * one to one (Entity/Store -> Entity)
  * one to many (Entity/Store -> List -> Entity)
  * many to many (Entity/Store -> IndexedList -> Entity)
* ActionCreators dispatch actions.
* Batch change events on stores within a dispatch iteration to simplify store interactions.


#### Features we'd like to add
 - [ ] Webpack Hot Loader
 - [ ] Chrome Devtools Extension(s)
 - [ ] State snapshots
 - [ ] Replayable action logs

## Dependencies
* lodash
* immutable-js

## NOTE: Upgrading to capacitor > 0.2.x from capacitor < 0.2.x

Stores now use immutable js for the data. The API is still the same but the data returned is now instances of immutable's classes. See https://github.com/facebook/immutable-js for usage. Unfortunately this completely breaks backwards compatibility.
