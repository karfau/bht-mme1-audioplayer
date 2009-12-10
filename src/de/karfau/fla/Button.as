package de.karfau.fla
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class Button extends MovieClip
	{
		
		public static const STATE_UP:String = "_up";
		public static const STATE_OVER:String = "_over";
		public static const STATE_DOWN:String = "_down";
		
		public var label:TextField;
		
		private var currentState:String = STATE_UP;
		
		public function Button () {
			this.buttonMode = true;
			this.mouseChildren = false;
			this.tabEnabled = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_enabledAlpha = alpha;
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseToStateHandler);
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseToStateHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseToStateHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseToStateHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseToStateHandler);
			this.gotoAndStop(STATE_UP);
		}
		
		protected function enterFrameHandler (event:Event):void {
			if (forcedState)
				this.gotoAndStop(forcedState);
			else
				this.stop();
		}
		
		protected function mouseToStateHandler (event:MouseEvent):void {
			if (forcedState)
				this.gotoAndStop(forcedState);
			else
				switch (event.type) {
				case MouseEvent.MOUSE_MOVE:
				case MouseEvent.MOUSE_OVER:
					this.gotoAndStop(STATE_OVER);
					break;
				case MouseEvent.MOUSE_DOWN:
					this.gotoAndStop(STATE_DOWN);
					break;
				case MouseEvent.MOUSE_OUT:
				case MouseEvent.MOUSE_UP:
					this.gotoAndStop(STATE_UP);
					break;
			}
		}
		
		/*		public function get labelText ():String {
			 return label.text;
			 }
		 */
		public function set labelText (value:String):void {
			trace(value);
			if (label)
				label.text = value;
		}
		
		private var _enabled:Boolean;
		private var _disabledAlpha:Number = 0.6;
		private var _enabledAlpha:Number = 1;
		
		/**
		 *
		 **/
		override public function set enabled (value:Boolean):void {
			if (enabled != value) {
				if (!value)
					_enabledAlpha = alpha;
				
				alpha = (value ? _enabledAlpha : _disabledAlpha);
			}
			super.enabled = value;
		}
		
		override public function dispatchEvent (event:Event):Boolean {
			if (enabled)
				return super.dispatchEvent(event);
			return false;
		}
		
		/**
		 *
		 **/
		public var _forcedState:String;
		
		/**
		 *
		 **/
		public function set forcedState (value:String):void {
			_forcedState = value;
			gotoAndPlay(value ? value : STATE_UP);
		}
		
		/** @private */
		public function get forcedState ():String {
			return _forcedState;
		}
	
	}
}