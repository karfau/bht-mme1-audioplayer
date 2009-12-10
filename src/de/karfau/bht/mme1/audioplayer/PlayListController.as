package de.karfau.bht.mme1.audioplayer
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class PlayListController
	{
		private var _playlist:Array = [];
		private var _currentTrack:uint = 0;
		
		private var _onCurrentTrackChanged:Signal = new Signal(uint);
		private var _onPlayListChanged:Signal = new Signal(Array);
		
		public function PlayListController (playList:Array=null) {
			if (playList)
				setPlaylist(playList);
		}
		
		public function get currentTrack ():uint {
			return _currentTrack;
		}
		
		/** dispatched when onCurrentTrackChanged
		 * listener-parameters:(currentTrackIndex:uint)**/
		public function get onCurrentTrackChanged ():ISignal {
			return _onCurrentTrackChanged;
		}
		
		/** dispatched when onPlayListChanged
		 * listener-parameters: (playlist:Array)**/
		public function get onPlayListChanged ():ISignal {
			return _onPlayListChanged;
		}
		
		public function get playlist ():Array {
			return _playlist;
		}
		
		public function setPlaylist (value:Array):void {
			if (!value) {
				_playlist = [];
			} else {
				_playlist = value;
			}
			_onPlayListChanged.dispatch(_playlist);
			___forceUpdateCurrentTrack = true;
			setCurrentTrack(_currentTrack);
		}
		
		private var ___forceUpdateCurrentTrack:Boolean = false;
		
		public function setCurrentTrack (value:uint):void {
			arguments.callee == setPlaylist
			if (___forceUpdateCurrentTrack || _currentTrack != value || _currentTrack >= playlist.length) {
				if (value >= playlist.length) {
					value = 0;
				}
				_currentTrack = value;
				_onCurrentTrackChanged.dispatch(_currentTrack);
			}
			___forceUpdateCurrentTrack = false;
		}
		
		public function get currentTrackFileName ():String {
			if (playlist.length == 0)
				return "No Items in Playlist";
			return playlist[_currentTrack];
		}
	
	}
}