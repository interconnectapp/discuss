---
browserify: true
---

Polymer('rtc-videoproc', {
	fps: 0.2,
	mime: 'image/jpeg',
	quality: 0.8,
	greedy: true,
	filter: null,  // grayscale
	filters: null,
	src: null,
	videoproc: null,
	imageURI: null,
	ready: function(){
		this.filters = {};
		this.filters.blue = function(imageData) {
			var channels = imageData.data;
			var rgb = [];
			var rgbAvg;
			var alpha;
			var ii;

			// check that we have channels is divisible by four (just as a safety)
			if (channels.length % 4 !== 0) {
				return;
			}

			// iterate through the data
			// NOTE: decrementing loops are fast but you need to know that you will
			// hit 0 using this logic otherwise it will run forever (only 0 is falsy)
			for (ii = channels.length; ii -= 4; ) {
				// get the rgb tuple
				rgb = [channels[ii], channels[ii + 1], channels[ii + 2]];

				// get the alpha value
				alpha = channels[ii + 3];

				// calculate the rgb average
				rgbAvg = (rgb[0] + rgb[1] + rgb[2] ) / 4;

				channels[ii] = rgbAvg;
				channels[ii + 1] = rgbAvg;
				channels[ii + 2] = rgbAvg*1.4;
			}

			return true;
		};
	},
	refresh: function(){
		var me = this;
		if ( me.src && me.filters[me.filter] ) {
			me.videoproc = require('rtc-videoproc')(me.src, me.$.canvas, {
				fps: me.fps,
				greedy: me.greedy,
				filter: me.filters[me.filter]
			});

			me.videoproc.on('frame', function() {
				me.imageURI = me.$.canvas.toDataURL(me.mime, me.quality);
			});
		}
	},
	filterChanged: function(oldValue, newValue) {
		var me = this;
		if ( newValue && !me.filters[newValue] ) {
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
							me.filters[me.filter] = require('rtc-filter-'+me.filter);
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