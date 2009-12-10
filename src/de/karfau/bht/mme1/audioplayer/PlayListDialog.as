package de.karfau.bht.mme1.audioplayer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import groups.PlayListDialogDesign;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class PlayListDialog extends PlayListDialogDesign
	{
		private var _onPlayListChanged:Signal = new Signal(Array);
		
		/**
		 *
		 **/
		private var _playlist:Array = [];
		private var _playlistString:String = "";
		
		/** dispatched when onPlayListChanged
		 * listener-parameters: (playlist:Array)**/
		public function get onPlayListChanged ():ISignal {
			return _onPlayListChanged;
		}
		
		/** @private */
		public function get playlist ():Array {
			return _playlist;
		}
		
		public function PlayListDialog () {
			this.visible = false;
			
			if (this.stage) {
				init();
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		/**
		 *
		 **/
		public function setPlaylist (value:Array):void {
			if (!value)
				value = [];
			var joined:String = value.join("\r");
			if (value.length == 0 || _playlist.join("\r") != joined) {
				
				listInput.text = joined;
				_playlistString = joined;
				doneBtn.enabled = false;
				
				_playlist = value;
				_onPlayListChanged.dispatch(value);
			}
		}
		
		private function init (e:Event=null):void {
			if (e)
				removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.x = this.stage.stageWidth / 2;
			this.y = (this.stage.stageHeight - this.height) / 2
			
			doneBtn.addEventListener(MouseEvent.CLICK, doneBtnClickHandler);
			doneBtn.enabled = false;
			
			listInput.addEventListener(Event.CHANGE, listInputChangeHandler);
			
			closeBtn.addEventListener(MouseEvent.CLICK, function ():void {visible = false;});
		}
		
		private function doneBtnClickHandler (event:MouseEvent):void {
			//if (trim(listInput.text) != _playlistString) {
			//remove whitespaces
			var arr:Array = trim(listInput.text).split("\r");
			var result:Array = [];
			for each (var filename:String in arr) {
				filename = trim(filename);
				if (filename)
					result.push(filename);
			}
			//put result of trimming back into field
			setPlaylist(result);
			//}
		}
		
		private function trim (value:String):String {
			return value.replace(/^\s?/, "").replace(/\s?$/, "");
		}
		
		private function listInputChangeHandler (event:Event):void {
			//listInput.removeEventListener(Event.CHANGE,listInputChangeHandler);
			doneBtn.enabled = (trim(listInput.text) != _playlistString);
		}
	}
}