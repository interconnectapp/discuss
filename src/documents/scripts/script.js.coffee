quickconnect = require("rtc-quickconnect")
media = require("rtc-media")
videoproc = require("rtc-videoproc")
captureConfig = require("rtc-captureconfig")
grayScaleFilter = require("rtc-videoproc/filters/grayscale")
$ = jQuery = require("jquery-browserify")



class App
	config: null
	signaller: null
	local: null
	peers: null

	constructor: (opts) ->
		@config = opts
		@local = {}
		@local.$el = @config.$el.find('.me').addClass('person')
		@local.el = @local.$el.get(0)
		@local.stream = false
		@local.media = false
		@local.video = false
		@local.canvas = false
		@peers = {}
		@

	# Create high bandwidth local stream
	createLocalStream: ->
		@local.media = media(@config.mediaOptions)

		@local.media.once('capture', (stream) =>
			console.log 'CAPTURED STREAM', stream
			@local.stream = stream
		)

		@local.video = $(@local.media.render(@local.el))
			.attr('muted', '')
			#.attr('controls', '')
			.addClass('mine')

		@

	createLocalSnaps: ->
		@local.canvas = videoproc(@local.el, @config.snapOptions)
		@local.canvas.style.display = "none"
		debugger
		@local.media.render(@local.canvas)

		# add the processing options
		@local.canvas.pipeline.add(grayScaleFilter)

		# once the canvas has been updated with the filters applied
		# capture the image data from the canvas and send via the data channel
		@local.canvas.addEventListener "postprocess", (event) =>
			dataURI = @local.canvas.toDataURL(@config.snapOptions.mime, @config.snapOptions.quality)
			for own peerId,peer of @peers
				if peer.streaming isnt true
					@sendMessage(peerId, {action:'snap', dataURI})

		@

	sendStream: (peerId) ->
		peer = @getPeer(peerId)
		if peer.streaming is false
			peer.connection.addStream(@local.stream)
			peer.streaming = true
			@sendMessage(peerId, {action:'sent-stream'})
		@

	cancelStream: (peerId) ->
		peer = @getPeer(peerId)
		if peer.streaming is true
			peer.connection.removeStream(@local.stream)  if @local.stream?
			peer.streaming = false
			@sendMessage(peerId, {action:'cancelled-stream'})
		@

	createConnection: ->
		@signaller = quickconnect(@config.signalHost, @config.connectionOptions)

		@signaller
			.createDataChannel("messages")

			.on("messages:open", (peerChannel, peerId) =>
				peer = @getPeer(peerId)
				peer.channel = peerChannel

				peer.channel.onmessage = (event) =>
					data = JSON.parse(event.data or '{}') or {}
					console.log('received message', data, 'from', peerId, 'event', event)  if data.action isnt 'snap'

					switch data.action
						when 'send-stream'
							console.log 'SEND STREAM', peerId
							if @local.stream
								@sendStream(peerId)

						when 'cancel-stream'
							console.log 'CANCEL STREAM', peerId
							@cancelStream(peerId)

						# NOTE:
						# This is here as the addstream event only works once
						# Rather than every time
						when 'sent-stream'
							console.log 'SENT STREAM', peerId
							@showPeerStream(peerId)
							@sendStream(peerId)

						when 'cancelled-stream'
							console.log 'CANCELLED STREAM', peerId
							@destroyPeerStream(peerId)
							@cancelStream(peerId)
							#@sendMessage(peerId, {action:'cancel-stream'})

						when 'snap'
							if peer.snap is false
								peer.snap = $("<img>")
									.data('peerId', peerId)
									.addClass('theirs')
									.attr('src', 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==')
									.appendTo(peer.el)

							peer.snap.attr("src", data.dataURI)
			)

			.on("peer:connect", (peerConnection, peerId, data, monitor) =>
				peer = @getPeer(peerId)
				peer.connection = peerConnection

				#setInterval(
				#	-> console.log 'REMOTE STREAMS:', peerId, peerConnection.getRemoteStreams()
				#	5000
				#)

				# NOTE:
				# The addstream event doesn't fire for streams that have been added previously
				# As such, add stream only fires the first time a stream is shared
				# For subsequent shares, we rely on sent-stream
				peerConnection.onaddstream = (event) =>
					console.log 'ADD STREAM', peerId
					peer.stream = event.stream
					@showPeerStream(peerId)

					#event.stream.onended = -> destroyPeerStream(peerId)
				#peerConnection.onremovestream = (event) -> destroyPeerStream(peerId)
		  	)

			.on("peer:leave", (peerId) =>
				@destroyPeer(peerId)
			)

		@

	getPeer: (peerId) ->
		return @peers[peerId] or @createPeer(peerId)

	createPeer: (peerId) ->
		peer = @peers[peerId] ?= {}
		peer.$el = $('<div>').addClass('peer person').appendTo(@config.$el.find('.peers'))
		peer.el = peer.$el.get(0)
		peer.streaming = false
		peer.snap = false
		peer.stream = false
		peer.media = false
		peer.video = false
		return peer

	destroyPeer: (peerId) ->
		@destroyPeerSnap(peerId)
		@destroyPeerStream(peerId)
		delete @peers[peerId]
		@

	destroyPeerSnap: (peerId) ->
		peer = @getPeer(peerId)

		if peer?.snap
			peer.snap.remove()
			peer.snap = false

		@

	destroyPeerStream: (peerId) ->
		peer = @getPeer(peerId)

		if peer?.media
			peer.media = false

		if peer?.video
			peer.video.remove()
			peer.video = false

		@

	showPeerStream: (peerId) ->
		peer = @getPeer(peerId)

		console.log 'SHOW STREAM BEFORE', peerId, peer.connection?.getRemoteStreams()

		if peer and peer.stream and peer.video is false
			console.log 'SHOW STREAM', peerId
			peer.media = media(peer.stream)  if peer.media is false
			peer.video = $(peer.media.render(peer.el))
				.data('peerId', peerId)
				#.attr('controls', '')
				.addClass('theirs')
			@destroyPeerSnap(peerId)

		@

	sendMessage: (peerId, data) ->
		peer = @getPeer(peerId)
		console.log('send message', data, 'to', peerId)  if data.action isnt 'snap'

		if peer and peer.channel
			message = JSON.stringify(data)
			peer.channel.send(message)

		@


	render: ->
		@config.$el.on("click", "img.theirs, video.theirs", (event) =>
			peerId = $(event.target).data('peerId')
			peer = @getPeer(peerId)
			if peer.video
				action = 'cancel-stream'
			else
				action = 'send-stream'
			@sendMessage(peerId, {action})
		)
		@

	setup: ->
		@createLocalStream()
		@createLocalSnaps()
		@createConnection()
		@render()
		@

###
$app = $('.app')
app = new App(
	el: $app.get(0)
	$el: $app
	signalHost: if location.href.indexOf('github.io') then 'http://rtc.io/switchboard/' else location.href.replace(/(^.*\/).*$/, "$1")
	connectionOptions:
		room: "demo-snaps"
		debug: false
	snapOptions:
		fps: 0.5
		mime: 'image/jpeg'
		quality: 0.8
		greedy: true  # keep generating snaps even when the user's tab is in the background
	mediaOptions:
		muted: false
		constraints: captureConfig("camera max:320x240").toConstraints()
)

app.setup()
###



## =======================================================

