Polymer('rtc-video', {
	src: null,
	video: null,
	muted: false,
	playing: true,
	ready: function(){
		this.refresh();
		this.refresh = this.refresh.bind(this);
	},
	refresh: function(){
		var me = this;
		var video = me.$.video;

		// Apply the element to our model for data binding
		me.video = video;

		// If we are playing, play the video
		if ( me.src && me.playing ) {
			setTimeout(function(){
				video.play();
			}, 0);
		}

		// If we are not playing, pause the video
		else {
			video.pause();
		}
	},
	srcChanged: function(){
		this.refresh();
	},
	playingChanged: function(){
		this.refresh();
	}
});