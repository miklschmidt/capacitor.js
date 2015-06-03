## Members
<dl>
<dt><a href="#dispatching">dispatching</a> : <code>boolean</code> ℗</dt>
<dd><p>Wether or not the dispatcher is currently dispatching.</p>
</dd>
<dt><a href="#storeID">storeID</a> : <code>integer</code> ℗</dt>
<dd><p>ID to use for the next store that gets registered.</p>
</dd>
<dt><a href="#stores">stores</a> : <code>object</code> ℗</dt>
<dd><p>Store registry.</p>
</dd>
<dt><a href="#isPending">isPending</a> : <code>object</code> ℗</dt>
<dd><p>Object for tracking pending store callbacks.</p>
</dd>
<dt><a href="#isPending">isPending</a> : <code>object</code> ℗</dt>
<dd><p>Object for tracking handled store callbacks.</p>
</dd>
<dt><a href="#isPending">isPending</a> : <code>string</code> ℗</dt>
<dd><p>The current action being dispatched, if any.</p>
</dd>
<dt><a href="#finalizers">finalizers</a> : <code>array</code> ℗</dt>
<dd><p>An array of callbacks to be called when the store is finished dispatching.</p>
</dd>
</dl>
<a name="dispatching"></a>
## dispatching : <code>boolean</code> ℗
Wether or not the dispatcher is currently dispatching.

**Kind**: global variable  
**Access:** private  
<a name="storeID"></a>
## storeID : <code>integer</code> ℗
ID to use for the next store that gets registered.

**Kind**: global variable  
**Access:** private  
<a name="stores"></a>
## stores : <code>object</code> ℗
Store registry.

**Kind**: global variable  
**Access:** private  
<a name="isPending"></a>
## isPending : <code>object</code> ℗
Object for tracking pending store callbacks.

**Kind**: global variable  
**Access:** private  
<a name="isPending"></a>
## isPending : <code>object</code> ℗
Object for tracking handled store callbacks.

**Kind**: global variable  
**Access:** private  
<a name="isPending"></a>
## isPending : <code>string</code> ℗
The current action being dispatched, if any.

**Kind**: global variable  
**Access:** private  
<a name="finalizers"></a>
## finalizers : <code>array</code> ℗
An array of callbacks to be called when the store is finished dispatching.

**Kind**: global variable  
**Access:** private  
