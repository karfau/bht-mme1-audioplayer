package de.karfau.bht.mme1.audioplayer
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(width="500", height="200", backgroundColor="#FFFFFF")]
	public class PlayerDC extends Sprite
	{
		
		private var player:PlayerDesign = new PlayerDesign();
		private var playlistDialog:PlayListDialog = new PlayListDialog();
		
		private var soundController:SoundController = new SoundController();
		private var playlistController:PlayListController = new PlayListController();
		
		private var ___nextTrackAndKeepPlaying:Boolean = false;
		
		public function PlayerDC () {
			
			addChild(this.player);
			addChild(playlistDialog);
			
			init();
		}
		
		/** adds support for going over length and under 0 of the playlist to choose the track at the other end of the playlist,
		 * wich is not supported by the playlistController */
		public function addToTrackIndex (value:int=1):void {
			
			var isPlaying:Boolean = soundController.isPlaying();
			
			//choose from playlist:
			var tmp:int = playlistController.currentTrack + value;
			var max:uint = playlistController.playlist.length - 1;
			if (tmp < 0)
				tmp = max;
			else if (tmp > max)
				tmp = 0;
			
			___nextTrackAndKeepPlaying = true;
			playlistController.setCurrentTrack(tmp);
		
		}
		
		private function init (e:Event=null):void {
			
			//LAYOUT
			this.player.x = stage.stageWidth / 2;
			this.player.y = stage.stageHeight / 2;
			
			//enables playing when app starts, needs to be done before playlist is set first time
			___nextTrackAndKeepPlaying = true;
			
			player.volumeControl.onVolumeChange.add(soundController.setVolume);
			
			playlistController.onCurrentTrackChanged.add(function (currentTrackIndex:uint):void {
					playCurrentTrack(___nextTrackAndKeepPlaying || soundController.isPlaying());
				});
			playlistController.onCurrentTrackChanged.add(player.infoDisplay.setCurrentIndex);
			
			playlistController.onPlayListChanged.add(player.infoDisplay.setPlaylist);
			playlistController.onPlayListChanged.add(playlistDialog.setPlaylist);
			playlistDialog.onPlayListChanged.add(playlistController.setPlaylist); //this currently inits the playlist by using the text that has been entered in the .fla
			
			soundController.onLoadingFailed.add(player.infoDisplay.displayError);
			soundController.onLoadingProgress.add(player.timeBar.displayLoadingProgress);
			soundController.onLoadingID3.add(player.infoDisplay.setCurrentID3);
			soundController.onPlaybackPositionChanged.add(player.timeBar.displayPlaybackProgress);
			soundController.onPlaybackCompleted.add(addToTrackIndex);
			
			soundController.onPlaybackPaused.add(player.controls.displayPause);
			soundController.onPlaybackStarted.add(player.controls.displayPlayback);
			soundController.onPlaybackStoped.add(player.controls.displayStop);
			soundController.onLoadingOpen.add(function ():void {
					player.infoDisplay.displayLoading(playlistController.currentTrackFileName);
				});
			
			player.controls.onPlayPause.add(soundController.togglePlayBack);
			player.controls.onStop.add(soundController.stopSound);
			player.controls.onNavigateTrack.add(addToTrackIndex);
			
			player.infoDisplay.onOpenPlaylist.add(function ():void {
					playlistDialog.visible = true;
				});
			player.infoDisplay.onTrackNumberInput.add(playlistController.setCurrentTrack);
			
			player.timeBar.onNavigateInTrack.add(function (startTime:Number):void {
				/*setting onlyContinue to true is not working:
					 it sets the currentposition to 0 and pauses (maybe an issue with a timer that calls updateCurrentPosition)*/
					soundController.playSound(startTime, false);
				});
			
			playlistController.setPlaylist(["song01.mp3", "song02.mp3", "CD2.mp3", "NotThere.mp3"]);
		
		}
		
		private function displayError (msg:String):void {
			trace(msg);
		}
		
		private function playCurrentTrack (playNow:Boolean):void {
			___nextTrackAndKeepPlaying = false;
			soundController.loadSound(playlistController.currentTrackFileName, playNow);
		/*if(!playNow)
			 soundController.onLoadingProgress.addOnce(function(n:uint,t:uint):void{
			 soundController.updateCurrentPosition();
		 });*/
		}
	}
}