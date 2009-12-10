package de.karfau.fla
{
	import buttons.NoteWhiteBlue;
	
	import de.karfau.signals.PropertyRelaySignal;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.media.ID3Info;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import org.osflash.signals.IDeluxeSignal;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class InfoDisplayBase extends Sprite
	{
		
		public var currentTrackInput:TextField;
		public var tracksTotalLbl:TextField;
		public var artistLbl:TextField;
		public var titleLbl:TextField;
		public var playListBtn:NoteWhiteBlue;
		
		private var _onOpenPlaylist:PropertyRelaySignal;
		private var _onTrackNumberInput:Signal = new Signal(uint);
		
		private var _playlistItemCount:uint = 0;
		
		private var _currentID3:ID3Info;
		private var _currentFile:String;
		
		/** dispatched when playlistBtn is clicked **/
		public function get onOpenPlaylist ():IDeluxeSignal {
			return _onOpenPlaylist;
		}
		
		/** dispatched on trackNumber-Input
		 *  listener-parameters: (newTrackNumber:uint) **/
		public function get onTrackNumberInput ():ISignal {
			return _onTrackNumberInput;
		}
		
		public function InfoDisplayBase () {
			playListBtn.buttonMode = true;
			_onOpenPlaylist = new PropertyRelaySignal(playListBtn, MouseEvent.CLICK, MouseEvent);
			currentTrackInput.addEventListener(Event.CHANGE, currentTrackInputHandler);
			currentTrackInput.addEventListener(KeyboardEvent.KEY_UP, currentTrackInputHandler);
			currentTrackInput.addEventListener(FocusEvent.FOCUS_OUT, currentTrackInputHandler);
		}
		
		public function setCurrentID3 (id3:ID3Info):void {
			_currentID3 = id3;
			if (id3) {
				applyText([id3.artist + " - " + id3.album, id3.songName]);
			} else {
				applyText(["loading " + _currentFile, "no id3 available"]);
			}
		}
		
		public function setPlaylist (value:Array):void {
			_playlistItemCount = value.length;
			tracksTotalLbl.text = String(_playlistItemCount);
		}
		
		public function setCurrentIndex (index:uint):void {
			currentTrackInput.text = String(index + 1);
		}
		
		private function currentTrackInputHandler (event:Event):void {
			var value:uint = uint(currentTrackInput.text) - 1;
			if (!displayInputError(value == 0 || value > _playlistItemCount)) {
				if (event is FocusEvent || (event is KeyboardEvent && KeyboardEvent(event).keyCode == Keyboard.ENTER))
					_onTrackNumberInput.dispatch(value);
			}
		}
		
		private function displayInputError (inputHasError:Boolean):Boolean {
			currentTrackInput.border = inputHasError;
			currentTrackInput.borderColor = inputHasError ? 0xFF0000 : 0x5588FF;
			return inputHasError;
		}
		
		public function displayError (error:String):void {
			var arr:Array = [error];
			if (error.indexOf(":") >= 0)
				arr = error.split(":", 2);
			applyText(arr, 0xFF0000);
		}
		
		public function displayLoading (fileName:String):void {
			if (!fileName) {
				_currentFile = "";
				setCurrentID3(null);
				displayError("empty playlist");
			} else {
				_currentFile = fileName;
				setCurrentID3(null);
			}
		}
		
		private function applyText (textArr:Array, color:uint=0xFFFFFF):void {
			var elements:Array = [artistLbl, titleLbl];
			if (!textArr)
				textArr = ["", ""];
			for (var i:uint = 0; i < elements.length; i++) {
				if (textArr.length == i)
					textArr.push("");
				TextField(elements[i]).textColor = color;
				TextField(elements[i]).text = textArr[i];
			}
		}
	
	}
}