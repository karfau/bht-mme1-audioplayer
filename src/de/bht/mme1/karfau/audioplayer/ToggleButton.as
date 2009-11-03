package de.bht.mme1.karfau.audioplayer
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	public class ToggleButton extends SimpleButton
	{
		private var _selected:Boolean = false;
		
		private var selectedState:DisplayObject;
		private var selectedOver:DisplayObject;
		private var unselectedState:DisplayObject;
		private var unselectedOver:DisplayObject;
		
		public function ToggleButton(upState:DisplayObject=null, overState:DisplayObject=null, downState:DisplayObject=null, hitTestState:DisplayObject=null)
		{
			super(upState, overState, downState, hitTestState);
			this.selectedState = downState;
			this.selectedOver = hitTestState;
			this.unselectedState = upState;
			this.unselectedOver = overState;
			super.addEventListener(MouseEvent.CLICK, handleClick,false, 10);
		}
		
		private function handleClick(event:MouseEvent):void{
			this._selected = !this._selected;
			doToggle();
		}
		
		private function doToggle():void{
			if(this._selected){
				this.upState = selectedState;
				this.overState = selectedOver;
				this.downState = unselectedState;
			}else{
				this.upState = unselectedState;
				this.overState = unselectedOver;
				this.downState = selectedState;
			}
			
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;
		}
		
		
		
	}
}