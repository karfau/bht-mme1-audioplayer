package de.bht.mme1.karfau.audioplayer
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Player extends MovieClip
	{
		
		//Options
		private var _repeat:Boolean = true;
		private var _shuffle:Boolean = true;
		
		
		
		//components from fla
		public var repeatBtn:ToggleButton;
		public var shuffleBtn:ToggleButton;
		
		
		public function Player()
		{
			repeatBtn.selected = _repeat;
			repeatBtn.addEventListener(MouseEvent.CLICK,handleOptionClick);
		}
		
		
		private function handleOptionClick(event:MouseEvent):void{
			switch(event.target){
				case repeatBtn: 
					_repeat = repeatBtn.selected;
					break;
				case shuffleBtn: 
					_shuffle = shuffleBtn.selected;
					break;
			}
		}
		
	}
}