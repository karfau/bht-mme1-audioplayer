package de.karfau.fla
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	
	public class IconButton extends SimpleButton
	{
		
		public function IconButton (upState:DisplayObject=null, overState:DisplayObject=null, downState:DisplayObject=null, hitTestState:DisplayObject=null) {
			super(upState, overState, downState, hitTestState);
			states = [upState, overState, downState, hitTestState];
//			this.
		}
		
		private var _icon:Icon;
		
		private var states:Array;
		
		public function get icon ():Icon {
			return _icon;
		}
		
		public function set icon (value:Icon):void {
			/*			if(_icon){
				 for each(var state:DisplayObject  in states){
				 if(state){
				 state.
				 }
				 }
				 }
			 */
			_icon = value;
		}
	}
}