package de.karfau.fla
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	
	public class IconButton extends SimpleButton
	{
		
		public var icon:Icon;
		
		public function IconButton(upState:DisplayObject=null, overState:DisplayObject=null, downState:DisplayObject=null, hitTestState:DisplayObject=null)
		{
			super(upState, overState, downState, hitTestState);
		}
	}
}