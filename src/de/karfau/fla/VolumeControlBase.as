package de.karfau.fla
{
	import buttons.VolumeBox;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	import status.VolumeInnerCircle;
	
	public class VolumeControlBase extends Sprite
	{
		private static const BTN_MUTE_FRAME:String = "_mute";
		
		public var scaleCircle:VolumeInnerCircle;
		public var boxBtn:VolumeBox;
		
		private var _lvlBeforeMute:Number;
		private var _scaleTotalWidth:Number;
		
		private var _onVolumeChange:Signal = new Signal(Number);
		
		/** dispatched when onVolumeChange
		 * listener-parameters: (lvl:Number)**/
		public function get onVolumeChange ():ISignal {
			return _onVolumeChange;
		}
		
		public function VolumeControlBase () {
			_scaleTotalWidth = scaleCircle.width / 2;
			
			this.addEventListener(MouseEvent.CLICK, mouseScaleHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseScaleHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseScaleHandler);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		
		/**
		 * mouseClickHandler function
		 *
		 **/
		private function mouseScaleHandler (event:MouseEvent):void {
			switch (event.target) {
				case boxBtn:
					if (event.type == MouseEvent.CLICK)
						toggleMute();
					break;
				default:
					if (event.type == MouseEvent.MOUSE_DOWN) {
						this.addEventListener(MouseEvent.MOUSE_MOVE, mouseScaleHandler);
					} else if (event.type == MouseEvent.MOUSE_UP) {
						this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseScaleHandler);
					}
					var x:Number = event.currentTarget.mouseX;
					var y:Number = event.currentTarget.mouseY;
					applyVolume(Math.sqrt(x * x + y * y) / _scaleTotalWidth);
			}
		}
		
		/**
		 * MouseWheelHandler function
		 *
		 **/
		private function mouseWheelHandler (event:MouseEvent):void {
			var mult:int = (event.delta < 0 ? -1 : 1);
			var percentDelta:Number = ((mult * event.delta) / 150) * mult;
			if (volume + percentDelta <= 0) {
				applyVolume(0);
			} else if (volume + percentDelta >= 1) {
				applyVolume(1);
			} else {
				applyVolume(volume + percentDelta);
			}
		
		}
		
		private function toggleMute ():void {
			if (scaleCircle.scaleX == 0) {
				applyVolume(_lvlBeforeMute);
				_lvlBeforeMute = 0;
			} else {
				_lvlBeforeMute = volume;
				applyVolume(0);
			}
		}
		
		private function applyVolume (percent:Number):void {
			if (percent < 0) {
				percent = 0;
			} else if (percent > 1) {
				percent = 1;
			}
			if (this.volume != percent) {
				scaleCircle.scaleX = percent;
				scaleCircle.scaleY = percent;
				boxBtn.forcedState = (percent == 0 ? BTN_MUTE_FRAME : null);
				_onVolumeChange.dispatch(percent);
			}
		}
		
		public function get volume ():Number {
			return scaleCircle.scaleX;
		}
	}
}