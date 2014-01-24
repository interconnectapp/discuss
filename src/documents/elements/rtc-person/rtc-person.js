Polymer('rtc-person', {
	video: null,
	streaming: false,
	name: null,
	muted: false,
	streamURI: null,
	snapshotURI: 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==',
	ready: function(){
		this.refresh();
	},
	refresh: function(){
		var me = this;
		var name = me.$.name;
		var video = me.$.video;
		var image = me.$.image;

		// If we are streaming, show the video
		if ( me.streamURI && me.streaming ) {
			video.className = '';
			image.className = 'hidden';
		}

		// If we are not streaming, show the snapshot
		else if ( me.snapshotURI ) {
			video.className = 'hidden';
			image.className = '';
		}

		else {
			image.className = video.className = 'hidden';
		}

		// Hide the name
		setTimeout(function(){
			name.className = '';
		}, 5000);
	},
	streamURIChanged: function(){
		this.refresh();
	},
	streamingChanged: function(){
		this.refresh();
	}
});