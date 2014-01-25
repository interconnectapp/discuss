Polymer('rtc-person', {
	video: null,
	streaming: false,
	name: null,
	status: null,
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
		var spinner = me.$.spinner;
		var status = me.$.status;

		// If we are streaming, show the video
		me.status = 'waiting';
		if ( me.streaming ) {
			if ( me.streamURI ) {
				me.status = 'streaming';
			} else {
				me.status = 'connecting';
			}
		}

		// If we are not streaming, show the snapshot
		else if ( me.snapshotURI ) {
			me.status = 'relaxing';
		}

		// Apply the state
		switch ( me.status ) {
			case 'waiting':
			case 'connecting':
				spinner.className = '';
				image.className = video.className = 'hidden';
				break;

			case 'relaxing':
				image.className = '';
				spinner.className = video.className = 'hidden';
				break;

			case 'streaming':
				video.className = '';
				spinner.className = image.className = 'hidden';
				break;
		}

		// Show the status, then hide it
		status.className = 'initial';
		setTimeout(function(){
			status.className = '';
		}, 1000);

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