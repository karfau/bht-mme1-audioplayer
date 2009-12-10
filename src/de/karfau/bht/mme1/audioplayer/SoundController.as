package de.karfau.bht.mme1.audioplayer
{
	import de.karfau.signals.PropertyRelaySignal;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import org.osflash.signals.IDeluxeSignal;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class SoundController
	{
		public static const PLAYBACK:int = 1;
		public static const PAUSE:int = 0;
		public static const STOP:int = -1;
		
		private var updateIntervalId:uint;
		private var _playbackState:int = STOP;
		
		private var _loadingFailed:PropertyRelaySignal;
		private var _onLoadingOpen:PropertyRelaySignal;
		private var _loadingProgress:PropertyRelaySignal;
		private var _onLoadingID3:Signal = new Signal(ID3Info);
		private var _onInternalID3:PropertyRelaySignal;
		private var _loadingCompleted:PropertyRelaySignal;
		
		private var _playbackCompleted:PropertyRelaySignal;
		private var _playbackStarted:Signal = new Signal();
		private var _playbackPositionChanged:Signal = new Signal(Number, Number);
		private var _playbackPaused:Signal = new Signal();
		private var _playbackStoped:Signal = new Signal();
		
		private var _sound:Sound = new Sound();
		
		private var _currentChannel:SoundChannel = new SoundChannel();
		
		private var _currentPosition:Number = 0;
		
		private var _currentSoundTransform:SoundTransform = new SoundTransform();
		
		/** the current playback-position. */
		
		private function get channelPosition ():Number {
			return _currentChannel.position;
		}
		
		public function get currentPosition ():Number {
			return applyCurrentPosition(channelPosition);
		}
		
		public function set currentPosition (value:Number):void {
			playSound(value);
		}
		
		public function get currentVolume ():Number {
			return _currentSoundTransform.volume;
		}
		
		/** dispatched when a sound-file is loaded completly **/
		public function get onLoadingCompleted ():IDeluxeSignal {
			return _loadingCompleted;
		}
		
		/** dispatched whenever an error occures (e.g. IOErrorEvent while loading file)
		 * parameters for listener (errorMessage:String)**/
		public function get onLoadingFailed ():IDeluxeSignal {
			return _loadingFailed;
		}
		
		/** dispatched when ID3-tags are available **/
		public function get onLoadingID3 ():ISignal {
			return _onLoadingID3;
		}
		
		/** dispatched when onLoadingOpen
		 * listener-parameters: ()**/
		public function get onLoadingOpen ():IDeluxeSignal {
			return _onLoadingOpen;
		}
		
		/** dispatched whenever loading a sound-file has made progress
		 * parameters for listener (bytesLoaded:uint, bytesTotal:uint)**/
		public function get onLoadingProgress ():IDeluxeSignal {
			return _loadingProgress;
		}
		
		/** dispatched whenever playback is finished **/
		public function get onPlaybackCompleted ():IDeluxeSignal {
			return _playbackCompleted;
		}
		
		/** dispatched whenever the playback is paused**/
		public function get onPlaybackPaused ():ISignal {
			return _playbackPaused;
		}
		
		/** dispatched whenever the SoundController notices a change of the current position while playback
		 * this can be achived by calling updateCurrentPosition() as often as needed.**/
		public function get onPlaybackPositionChanged ():ISignal {
			return _playbackPositionChanged;
		}
		
		/** dispatched whenever the playback starts or resumes**/
		public function get onPlaybackStarted ():ISignal {
			return _playbackStarted;
		}
		
		/** dispatched whenever playback was stoped **/
		public function get onPlaybackStoped ():ISignal {
			return _playbackStoped;
		}
		
		public function get playbackState ():int {
			return _playbackState;
		}
		
		protected function set playbackState (value:int):void {
			if (value != _playbackState) {
				_playbackState = value;
				if (value == PLAYBACK) {
					updateIntervalId = setInterval(updateCurrentPosition, 200);
				}
			}
		}
		
		/** this is left public so that there is no need to write a lot of wrapper-methods to all those attributes (right now)*/
		public function get sound ():Sound {
			return _sound;
		}
		
		public function SoundController () {
			_loadingFailed = new PropertyRelaySignal(_sound, IOErrorEvent.IO_ERROR, IOErrorEvent, ["text"]);
			_loadingProgress = new PropertyRelaySignal(_sound, ProgressEvent.PROGRESS, ProgressEvent, ["bytesLoaded", "bytesTotal"]);
			_loadingCompleted = new PropertyRelaySignal(_sound, Event.COMPLETE, Event);
			_onLoadingOpen = new PropertyRelaySignal(_sound, Event.OPEN, Event);
			_onInternalID3 = new PropertyRelaySignal(_sound, Event.ID3, Event);
			_onInternalID3.add(function ():void {
					_onLoadingID3.dispatch(sound.id3);
				});
			_playbackCompleted = new PropertyRelaySignal(_currentChannel, Event.SOUND_COMPLETE, Event);
		}
		
		public function isPlaying ():Boolean {
			return _playbackState == PLAYBACK;
		}
		
		/**
		 * initialises loading of a new sound-file
		 **/
		public function loadSound (url:String, playNow:Boolean):void {
			
			if (url != _sound.url) {
				if (isPlaying() || !playNow)
					stopPlaying();
				
				_sound = new Sound(null, new SoundLoaderContext(5000));
				_loadingFailed.target = _sound;
				_loadingProgress.target = _sound;
				_loadingCompleted.target = _sound;
				_onInternalID3.target = _sound;
				_onLoadingOpen.target = _sound;
				_sound.load(new URLRequest(url));
				
				if (!playNow)
					_loadingProgress.addOnce(function (n:uint, t:uint):void {updateCurrentPosition();});
				
			}
			if (playNow)
				playSound();
		
		}
		
		public function stopSound ():void {
			stopPlaying();
		}
		
		public function pauseSound ():void {
			stopPlaying(true);
		}
		
		public function playSound (position:Number=-1, onlyContinue:Boolean=false):void {
			var wasPlaying:Boolean = isPlaying();
			if (wasPlaying)
				stopPlaying(true);
			
			if (position < 0)
				position = (_playbackState == PAUSE ? channelPosition : 0);
			//if (!onlyContinue || (wasPlaying && onlyContinue)) {
			this._currentChannel = _sound.play(position, 0, _currentSoundTransform);
			_playbackCompleted.target = _currentChannel;
			protected::playbackState = PLAYBACK;
			if (onlyContinue && !wasPlaying) {
				pauseSound();
			} else {
				_playbackStarted.dispatch();
			}
		}
		
		public function togglePlayBack ():void {
			if (isPlaying()) {
				pauseSound();
			} else {
				playSound();
			}
		}
		
		/** applys and dispatches the current postition depending on playbackState.
		 * is triggered by an interval while playbackState is PLAYBACK */
		public function updateCurrentPosition ():void {
			var before:Number = _currentPosition;
			if (_playbackState == STOP) {
				applyCurrentPosition(0);
			} else {
				applyCurrentPosition(channelPosition);
			}
			trace(_playbackState, ":", _currentPosition, "\nbefore:", before, "; soundlen:", _sound.length);
			if (_playbackState == STOP && before == _currentPosition && _sound.length > 0) {
				clearInterval(updateIntervalId);
			}
		}
		
		public function setVolume (volume:Number):void {
			_currentSoundTransform.volume = volume;
			if (_currentChannel)
				_currentChannel.soundTransform = _currentSoundTransform;
		}
		
		/**  */
		protected function applyCurrentPosition (value:Number):Number {
			if (value != _currentPosition) {
				_currentPosition = value;
			}
			//this is here so that skipping to next track will do an update on totalTime
			//alternative: cache totaltime and check both for modifications
			_playbackPositionChanged.dispatch(_currentPosition, _sound.length);
			if (_sound.length == 0)
				setTimeout(applyCurrentPosition, 100, value);
			return _currentPosition;
		}
		
		private function stopPlaying (pause:Boolean=false):void {
			if (pause == false || isPlaying()) { //this makes timeselection unavailable when paused: playbackState has to be PLAYBACK before
				_currentChannel.stop();
				protected::playbackState = (pause ? PAUSE : STOP);
				applyCurrentPosition((pause ? channelPosition : 0));
				if (pause) {
					_playbackPaused.dispatch();
					_playbackPositionChanged.dispatch(_currentPosition, _sound.length);
				} else {
					_playbackStoped.dispatch();
					
				}
			}
		}
	/*		private function soundRelay (event:Event):void {
		 if (event is IOErrorEvent)
		 _loadingFailed.dispatch(IOErrorEvent(event).text);
		 else if (event.type == Event.COMPLETE)
		 _loadingCompleted.dispatch();
		 else if (event is ProgressEvent) {
		 _loadingProgress.dispatch(ProgressEvent(event).bytesLoaded, ProgressEvent(event).bytesTotal);
		 _playbackTotalTimeChanged.dispatch(_sound.length);
		 }
		 }
		 private function channelRelay (event:Event):void {
		 if (event.type == Event.SOUND_COMPLETE)
		 _playbackCompleted.dispatch();
		 }
	 */
	}
}