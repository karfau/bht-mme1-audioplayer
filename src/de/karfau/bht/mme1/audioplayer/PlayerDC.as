package de.karfau.bht.mme1.audioplayer
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import de.karfau.bht.mme1.audioplayer.PlayerDesign;
	
	import icons.Repeat;
	import icons.Shuffle;
	
	public class PlayerDC extends MovieClip
	{
		public var player:PlayerDesign;
		
		public function PlayerDC()
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
			this.player.shuffleBtn.icon = new Shuffle();
			this.player.repeatBtn.icon = new Repeat();
			//repeatBtn.selected = _repeat;
			//repeatBtn.addEventListener(MouseEvent.CLICK,handleOptionClick);
		}
	}
}