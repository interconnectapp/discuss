---
browserify: true
---

var STAY_NOW_FOR_ = 20 * 1000 // ms
var moment = require('moment');

function prettyPrintDate_() {
	if (moment(this.datetime).diff(this.now) >= -STAY_NOW_FOR_) {
		this.prettyDateTime = 'Now';
	} else {
		this.prettyDateTime = moment(this.datetime).from(this.now); //.calendar()
	}
}

Polymer('hangout-message', {
	// ready: function() {
	//		 this.cancelUnbindAll();
	//	 },
	isother: false,
	profile: null,
	prettyDateTime: 'Now',
	datetimeChanged: function() {
		prettyPrintDate_.bind(this)();
	},
	nowChanged: function() {
		prettyPrintDate_.bind(this)();
	},
	fromChanged: function() {
		if (!this.isother) {
			this.classList.add('self');
			this.classList.remove('isother');
		} else {
			this.classList.add('isother');
			this.classList.remove('self');
		}
	},
	get nickname() {
		return this.from ? this.from.split(' ')[0] : '';
	}
});