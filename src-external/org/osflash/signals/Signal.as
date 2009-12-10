package org.osflash.signals
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	/**
	 * Signal dispatches events to multiple listeners.
	 * It is inspired by C# events and delegates, and by
	 * <a target="_top" href="http://en.wikipedia.org/wiki/Signals_and_slots">signals and slots</a>
	 * in Qt.
	 * A Signal adds event dispatching functionality through composition and interfaces,
	 * rather than inheriting from a dispatcher.
	 * <br/><br/>
	 * Project home: <a target="_top" href="http://github.com/robertpenner/as3-signals/">http://github.com/robertpenner/as3-signals/</a>
	 */
	public class Signal implements ISignal, IDispatcher
	{
		protected var _valueClasses:Array;		// of Class
		protected var listeners:Array;			// of Function
		protected var onceListeners:Dictionary;	// of Function
		
		/**
		 * Creates a Signal instance to dispatch events on behalf of a target object.
		 * @param	target The object the signal is dispatching events on behalf of.
		 * @param	valueClasses Any number of class references that enable type checks in dispatch().
		 * For example, new Signal(String, uint)
		 * would allow: signal.dispatch("the Answer", 42)
		 * but not: signal.dispatch(true, 42.5)
		 * nor: signal.dispatch()
		 */
		public function Signal(...valueClasses)
		{
			listeners = [];
			onceListeners = new Dictionary();
			if (!valueClasses) return;
			
			_valueClasses = valueClasses.concat();
			// loop backwards
			for (var i:int = _valueClasses.length; i--; )
			{
				if (!(_valueClasses[i] is Class))
				{
					throw new ArgumentError('Invalid valueClasses argument: item at index ' + i
						+ ' should be a Class but was:<' + _valueClasses[i] + '>.');
				}
			}
		}
		
		/** @inheritDoc */
		public function get valueClasses():Array { return _valueClasses; }
		
		/** @inheritDoc */
		public function get numListeners():uint { return listeners.length; }
		
		/** @inheritDoc */
		//TODO: @throws
		public function add(listener:Function):void
		{
			if (onceListeners[listener])
				throw new IllegalOperationError('You cannot addOnce() then add() the same listener without removing the relationship first.');
		
			createListenerRelationship(listener);
		}
		
		/** @inheritDoc */
		public function addOnce(listener:Function):void
		{
			if (listeners.indexOf(listener) >= 0 && !onceListeners[listener])
				throw new IllegalOperationError('You cannot add() then addOnce() the same listener without removing the relationship first.');
			
			createListenerRelationship(listener);
			onceListeners[listener] = true;
		}
		
		/** @inheritDoc */
		public function remove(listener:Function):void
		{
			listeners.splice(listeners.indexOf(listener), 1);
			delete onceListeners[listener];
		}
		
		/** @inheritDoc */
		public function removeAll():void
		{
			listeners.length = 0;
			onceListeners = new Dictionary();
		}
		
		/** @inheritDoc */
		public function dispatch(...valueObjects):void
		{
			var len:int = _valueClasses.length;
			for (var i:int = 0; i < len; i++)
			{
				if (!(valueObjects[i] is _valueClasses[i]))
					throw new ArgumentError('Value object <'+valueObjects[i]+'> is not an instance of <'+_valueClasses[i]+'>.');
			}

			//// Call listeners.
			if (!listeners.length) return;
			
			//TODO: investigate performance of various approaches
			
			var listener:Function;
			switch (valueObjects.length)
			{
				case 0:
					// Clone listeners array because add/remove may occur during the dispatch.
					for each (listener in listeners.concat())
					{
						if (onceListeners[listener]) remove(listener);
						listener();
					}
					break;
					
				case 1:
					for each (listener in listeners.concat())
					{
						if (onceListeners[listener]) remove(listener);
						listener(valueObjects[0]);
					}
					break;
					
				default:
					for each (listener in listeners.concat())
					{
						if (onceListeners[listener]) remove(listener);
						listener.apply(null, valueObjects);
					}
			}
		}
		
		protected function createListenerRelationship(listener:Function):void
		{
			// function.length is the number of arguments.
			if (listener.length < _valueClasses.length)
			{
				var argumentString:String = (listener.length == 1) ? 'argument' : 'arguments';
				throw new ArgumentError('Listener has '+listener.length+' '+argumentString+' but it needs at least '+_valueClasses.length+' to match the given value classes.');
			}
			
			// If there are no previous listeners, add the first one as quickly as possible.
			if (!listeners.length)
			{
				listeners[0] = listener;
				return;
			}
			
			// Don't add the same listener twice.
			if (listeners.indexOf(listener) >= 0)
				return;
				
			// Faster than push().
			listeners[listeners.length] = listener;
		}
	}
}
