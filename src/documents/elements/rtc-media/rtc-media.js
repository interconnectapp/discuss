---
browserify: true
---

Polymer('rtc-media', {
	capture: 'camera max:320x240',
	stream: null,
	streamURI: null,
	ready: function(){
		var me = this;
		var constraints = require('rtc-captureconfig')(me.capture).toConstraints();
		var media = require("rtc-media")({
			constraints: constraints
		});
		media.on('error', function(err){
			console.log('MEDIA FAILED because of', err);
		});
		media.once('capture', function(stream){
			me.stream = stream;
			me.streamURI = window.URL.createObjectURL(stream);
		});
	}
});