package de.karfau.fla
{
	import buttons.HandlerRed;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import status.LoadProgressBar;
	
	import text.PlaybackTooltip;
	import text.WhiteOnBlue;
	
	public class TimeBarBase extends Sprite
	{
		
		public var progressBar:LoadProgressBar;
		public var progressHandler:HandlerRed;
		public var totalTimeLbl:WhiteOnBlue;
		public var playbackTooltip:PlaybackTooltip;
		
		private var _onNavigateInTrack:Signal = new Signal(Number);
		
		/** dispatched when onNavigateInTrack **/
		public function get onNavigateInTrack ():ISignal {
			return _onNavigateInTrack;
		}
		
		public function TimeBarBase () {
			progressBar.buttonMode = true;
			progressBar.addEventListener(MouseEvent.MOUSE_OVER, displayTooltip);
			progressBar.addEventListener(MouseEvent.MOUSE_OUT, displayTooltip);
			progressBar.addEventListener(MouseEvent.MOUSE_MOVE, displayTooltip);
			progressBar.addEventListener(MouseEvent.CLICK, progressBarClickHandler);
			
			totalTimeLbl.addEventListener(MouseEvent.CLICK, totalTimeLblClickHandler);
			
			playbackTooltip.visible = false;
			progressHandler.x = progressBar.x;
		}
		
		private function totalTimeLblClickHandler (event:MouseEvent):void {
			_negativeTotal = !_negativeTotal;
			displayPlaybackProgress(_playbackPosition, _totalTime);
		}
		
		private function progressBarClickHandler (event:MouseEvent):void {
			_onNavigateInTrack.dispatch(_totalTime * (event.localX / progressBar.width));
		}
		
		/** scales the progressBar depending on now/total */
		public function displayLoadingProgress (now:uint, total:uint):void {
			var percent:Number = now / total;
			this.progressBar.scaleX = percent;
		}
		
		private var _totalTime:Number = 10000;
		private var _negativeTotal:Boolean = false;
		private var _playbackPosition:Number;
		
		private static function timeString (milliSeconds:Number):String {
			var date:Date = new Date(milliSeconds);
			var tmp:Array = [date.hoursUTC, date.minutesUTC, date.secondsUTC];
			var result:String = "";
			for (var i:int = 0; i < tmp.length; i++) {
				if (tmp[i] > 0 || i > 0) {
					result += (result.length > 0 ? ":" : "") + (tmp[i] < 10 ? "0" + tmp[i] : tmp[i]);
				}
			}
			return result;
		
		}
		
		public function set totalTime (value:Number):void {
			if (_totalTime != value) {
				_totalTime = value;
			}
			if (!_negativeTotal)
				totalTimeLbl.label.text = timeString(value);
		}
		
		public function set playbackPosition (value:Number):void {
			if (_totalTime && _playbackPosition != value) {
				_playbackPosition = value;
				progressHandler.x = progressBar.x + (_playbackPosition / _totalTime) * progressBar.width;
				progressHandler.labelText = timeString(value);
			}
		}
		
		/**
		 *
		 **/
		public function displayPlaybackProgress (current:Number, total:Number):void {
			totalTime = total;
			playbackPosition = current;
			if (this._negativeTotal)
				totalTimeLbl.label.text = "-" + timeString(total - current);
		}
		
		private function displayTooltip (event:MouseEvent):void {
			var percent:Number = event.localX / progressBar.width;
			switch (event.type) {
				case MouseEvent.MOUSE_OVER:
					this.playbackTooltip.visible = true;
				case MouseEvent.MOUSE_MOVE:
					this.playbackTooltip.x = event.localX - progressBar.width / 2;
					this.playbackTooltip.label.text = timeString(_totalTime * percent);
					break;
				case MouseEvent.MOUSE_OUT:
					this.playbackTooltip.visible = false;
					break;
			}
		}
	
	}
}