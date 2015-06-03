<a name="module_ActionCreator"></a>
## ActionCreator

* [ActionCreator](#module_ActionCreator)
  * [~ActionInstance](#module_ActionCreator..ActionInstance)
  * [~ActionCreator](#module_ActionCreator..ActionCreator)
    * [.dispatch(action, payload)](#module_ActionCreator..ActionCreator+dispatch)
    * [.createActionInstance(action, payload)](#module_ActionCreator..ActionCreator+createActionInstance)
    * [.generateRequestID()](#module_ActionCreator..ActionCreator+generateRequestID) ⇒ <code>Number</code>

<a name="module_ActionCreator..ActionInstance"></a>
### ActionCreator~ActionInstance
**Kind**: inner class of <code>[ActionCreator](#module_ActionCreator)</code>  
<a name="module_ActionCreator..ActionCreator"></a>
### ActionCreator~ActionCreator
**Kind**: inner class of <code>[ActionCreator](#module_ActionCreator)</code>  

* [~ActionCreator](#module_ActionCreator..ActionCreator)
  * [.dispatch(action, payload)](#module_ActionCreator..ActionCreator+dispatch)
  * [.createActionInstance(action, payload)](#module_ActionCreator..ActionCreator+createActionInstance)
  * [.generateRequestID()](#module_ActionCreator..ActionCreator+generateRequestID) ⇒ <code>Number</code>

<a name="module_ActionCreator..ActionCreator+dispatch"></a>
#### actionCreator.dispatch(action, payload)
Dispatches an action through the dispatcher

**Kind**: instance method of <code>[ActionCreator](#module_ActionCreator..ActionCreator)</code>  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>Action</code> | The action to dispatch |
| payload | <code>mixed</code> | Payload for the action |

<a name="module_ActionCreator..ActionCreator+createActionInstance"></a>
#### actionCreator.createActionInstance(action, payload)
Creates an action instance for dispatching

**Kind**: instance method of <code>[ActionCreator](#module_ActionCreator..ActionCreator)</code>  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>Action</code> | The action to dispatch |
| payload | <code>mixed</code> | Payload for the action |

<a name="module_ActionCreator..ActionCreator+generateRequestID"></a>
#### actionCreator.generateRequestID() ⇒ <code>Number</code>
Generates a request id. Useful for tracking specific requests in components.

**Kind**: instance method of <code>[ActionCreator](#module_ActionCreator..ActionCreator)</code>  
