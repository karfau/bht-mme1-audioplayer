package de.karfau.fla
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	[Event(name="blaBlub", type="flash.event.Event")]
	public class ControlsBase extends Sprite
	{
		
		public static const PLAYBACK:int = 1;
		public static const PAUSE:int = 0;
		public static const STOP:int = -1;
		
		public var playPauseBtn:SimpleButton;
		public var stopBtn:SimpleButton;
		public var previousBtn:SimpleButton;
		public var nextBtn:SimpleButton;
		
		private var _playPauseSignal:Signal = new Signal();
		private var _stopSignal:Signal = new Signal();
		private var _navigateTrackSignal:Signal = new Signal(int);
		
		public function ControlsBase () {
			super();
			this.addEventListener(MouseEvent.CLICK, mouseHandler);
		}
		
		/** dispatches whenever playPauseButton is clicked **/
		public function get onPlayPause ():ISignal {
			return _playPauseSignal;
		}
		
		/** dispatches whenever previous-/nextBtn is clicked **/
		public function get onNavigateTrack ():ISignal {
			return _navigateTrackSignal;
		}
		
		/** dispatches whenever stopBtn is clicked **/
		public function get onStop ():ISignal {
			return _stopSignal;
		}
		
		/** relays mouseclicks as signals*/
		private function mouseHandler (event:MouseEvent):void {
			switch (event.target) {
				case playPauseBtn:
					_playPauseSignal.dispatch();
					break;
				case stopBtn:
					_stopSignal.dispatch();
					break;
				case previousBtn:
					_navigateTrackSignal.dispatch(-1);
					break;
				case nextBtn:
					_navigateTrackSignal.dispatch(1);
					break;
			}
		}
		
		public function displayPause ():void {
			showState(PAUSE);
		}
		
		public function displayPlayback ():void {
			showState(PLAYBACK);
		}
		
		public function displayStop ():void {
			showState(STOP);
		}
		
		private function showState (state:int):void {
			this.stopBtn.enabled = state != STOP;
			stopBtn.alpha = (state == STOP ? 0.8 : 1.0);
		}
	}
}