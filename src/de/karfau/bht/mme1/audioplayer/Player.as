package de.karfau.bht.mme1.audioplayer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import icons.Repeat;
	import icons.Shuffle;
	
	public class Player extends PlayerDesign{
		
		//Options
		private var _repeat:Boolean = true;
		private var _shuffle:Boolean = true;		
		
		public function Player()
		{
			if(this.stage){ 
				init();
			}else{ 
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			this.shuffleBtn.icon = new Shuffle();
			this.repeatBtn.icon = new Repeat();
			//repeatBtn.selected = _repeat;
			repeatBtn.addEventListener(MouseEvent.CLICK,handleOptionClick);
		}
		
		private function handleOptionClick(event:MouseEvent):void{
			switch(event.target){
				case repeatBtn: 
					//_repeat = repeatBtn.selected;
					break;
				case shuffleBtn: 
					//_shuffle = shuffleBtn.selected;
					break;
			}
		}
		
	}
}