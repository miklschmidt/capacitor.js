<a name="module_ActionManager"></a>
## ActionManager

* [ActionManager](#module_ActionManager)
  * [~ActionManager](#module_ActionManager..ActionManager)
    * [.create(name)](#module_ActionManager..ActionManager+create) ⇒ <code>Action</code>
    * [.list()](#module_ActionManager..ActionManager+list) ⇒ <code>Array</code>
    * [.exists()](#module_ActionManager..ActionManager+exists) ⇒ <code>boolean</code>
  * [~actions](#module_ActionManager..actions) : <code>Object</code> ℗

<a name="module_ActionManager..ActionManager"></a>
### ActionManager~ActionManager
**Kind**: inner class of <code>[ActionManager](#module_ActionManager)</code>  

* [~ActionManager](#module_ActionManager..ActionManager)
  * [.create(name)](#module_ActionManager..ActionManager+create) ⇒ <code>Action</code>
  * [.list()](#module_ActionManager..ActionManager+list) ⇒ <code>Array</code>
  * [.exists()](#module_ActionManager..ActionManager+exists) ⇒ <code>boolean</code>

<a name="module_ActionManager..ActionManager+create"></a>
#### actionManager.create(name) ⇒ <code>Action</code>
Method for creating an action

**Kind**: instance method of <code>[ActionManager](#module_ActionManager..ActionManager)</code>  
**Returns**: <code>Action</code> - the created action.  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The (unique) name of the action. |

<a name="module_ActionManager..ActionManager+list"></a>
#### actionManager.list() ⇒ <code>Array</code>
Method for listing all existing actions

**Kind**: instance method of <code>[ActionManager](#module_ActionManager..ActionManager)</code>  
**Returns**: <code>Array</code> - list of existing actions  
<a name="module_ActionManager..ActionManager+exists"></a>
#### actionManager.exists() ⇒ <code>boolean</code>
Method to check if an action exists

**Kind**: instance method of <code>[ActionManager](#module_ActionManager..ActionManager)</code>  
<a name="module_ActionManager..actions"></a>
### ActionManager~actions : <code>Object</code> ℗
a list of all existing actions

**Kind**: inner property of <code>[ActionManager](#module_ActionManager)</code>  
**Access:** private  
