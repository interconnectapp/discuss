var timerId_ = null;

function lastMesageWasFromMe_() {
	if (!this.messages.length) {
		return false;
	}
	return !this.messages[this.messages.length - 1].isother;
}

Polymer('hangout-module', {
	now: new Date().toISOString(),
	minimized: false,
	messages: [],
	ready: function() {
		//this.cancelUnbindAll();

		// TODO: Setup timer in parent element that manages updates.
		timerId_ = window.setInterval(function() {
			this.now = new Date().toISOString();
		}.bind(this), 1000);

		this.asyncMethod(function() {
			this.$.msg.focus();
		});
	},
	removed: function() {
		window.clearInterval(timerId_);

		console.log('Close hangout with ' + this.from + '.')
	},
	keyUp: function(e, details, sender) {
		if (e.keyCode == 13 && sender.value) { // Enter

			// If we were last sender, append to existing message.
			// Otherwise, create a new message bubble.
			if ( lastMesageWasFromMe_.call(this) ) {
				var message = this.messages[this.messages.length - 1];
				message.msg.push(sender.value);
				message.datetime = new Date().toISOString();
			} else {
				this.messages.push({
					profile: this.profile,
					datetime: new Date().toISOString(), //toLocaleTimeString()
					msg: [sender.value]
				});
			}

			sender.value = '';

			this.asyncMethod(function() {
				this.$.discussion.scrollTop = this.$.discussion.scrollHeight;
			});
		}
	},
	minimize: function(e, details, sender) {
		//e.stopPropagation();
		this.minimized = !this.minimized;
	},
	close: function(e, details, sender) {
		//e.stopPropagation();
		this.remove();
	}
});