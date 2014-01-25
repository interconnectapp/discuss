Polymer('rtc-videoproc', {
	fps: 0.5,
	mime: 'image/jpeg',
	quality: 0.8,
	greedy: true,
	filter: null,  // grayscale
	filterMethod: null,
	src: null,
	videoproc: null,
	imageURI: null,
	refresh: function(){
		var me = this;
		if ( me.src && me.filterMethod ) {
			me.videoproc = require('rtc-videoproc')(me.src, me.$.canvas, {
				fps: me.fps,
				greedy: me.greedy,
				filter: me.filterMethod
			});

			me.videoproc.on('frame', function() {
				me.imageURI = me.$.canvas.toDataURL(me.mime, me.quality);
			});
		}
	},
	filterChanged: function(oldValue, newValue) {
		var me = this;
		if ( newValue ) {
			var filterSource = '//wzrd.in/bundle/rtc-filter-'+newValue+'@latest';
			var dominject = require('dominject');
			dominject({
				type: 'script',
				url: filterSource,
				next: function(err, element) {
					if ( err ) {
						console.log(err);
					} else {
						try {
							me.filterMethod = require('rtc-filter-'+me.filter);
						} catch (err) {
							console.log(err);
							return;
						}

						me.refresh.call(me);
					}
				}
			});
		}
	},
	srcChanged: function(oldValue, newValue) {
		this.refresh();
	}
});