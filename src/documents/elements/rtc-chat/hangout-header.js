Polymer('hangout-header', {
	// ready: function() {
	//		this.cancelUnbindAll();
	//	},
	applyAuthorStyles: true,
	minimizeMe: function(e, details, sender) {
		this.fire('minimize');
	},
	closeMe: function(e, details, sender) {
		// TODO: close button target isn't fired first. Event delegation on header element is instead.
		if (sender == this.$.close) {
			this.fire('close');
		}
	}
});