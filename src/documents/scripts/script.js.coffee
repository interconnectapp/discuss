quickconnect = require("rtc-quickconnect")
media = require("rtc-media")
videoproc = require("rtc-videoproc")
captureConfig = require("rtc-captureconfig")
grayScaleFilter = require("rtc-videoproc/filters/grayscale")
$ = jQuery = require("jquery-browserify")

config =
	signalHost: location.href.replace(/(^.*\/).*$/, "$1")
	connectionOptions:
		room: "demo-snaps"
		debug: false
	snapOptions:
		fps: 1 # 0.1
		mime: 'image/jpeg'
		quality: 0.8

signaller = null
peerConnections = {}
peerChannels = {}
snapElements = {}
streamElements = {}
localMediaStream = null
peerBroadcastStreamStatus = {}
$body = null

# create a video processing canvas that will capture an update every second
canvas = videoproc(document.body, config.snapOptions)

# capture media and render to the canvas
localMedia = media(constraints: captureConfig("camera max:320x240").toConstraints())
localMedia.render(canvas)
canvas.style.display = "none"
localVideo = localMedia.render(document.body)
$localVideo = $(localVideo).addClass('mine')

# add the processing options
canvas.pipeline.add(grayScaleFilter)

# once the canvas has been updated with the filters applied
# capture the image data from the canvas and send via the data channel
canvas.addEventListener "postprocess", (event) ->
	dataURI = canvas.toDataURL(config.snapOptions.mime, config.snapOptions.quality)
	for own peerId,peerChannel of peerChannels
		if peerBroadcastStreamStatus[peerId] isnt true
			peerChannel.send(JSON.stringify {action:'snap', dataURI})

signaller = quickconnect(config.signalHost, config.connectionOptions)
$body = $(document.body)

destroyPeerSnap = (peerId) ->
	if snapElements[peerId]?
		snapElements[peerId].remove()
		delete snapElements[peerId]

destroyPeerStream = (peerId) ->
	if streamElements[peerId]?
		streamElements[peerId].remove()
		delete streamElements[peerId]

destroyPeer = (peerId) ->
	destroyPeerSnap(peerId)
	destroyPeerStream(peerId)

	delete peerChannels[peerId]
	delete peerBroadcastStreamStatus[peerId]


signaller
	.createDataChannel("messages")

	.on("messages:open", (peerChannel, peerId) ->
		peerChannels[peerId] = peerChannel

		peerChannel.onmessage = (event) ->
			data = JSON.parse(event.data or '{}') or {}
			console.log 'received message', data, event

			switch data.action
				when 'request-stream'
					if peerBroadcastStreamStatus[peerId]? is false and localMediaStream
						peerConnections[peerId].addStream(localMediaStream)
						peerBroadcastStreamStatus[peerId] = true

				when 'cancel-stream'
					if peerBroadcastStreamStatus[peerId] is true
						peerConnections[peerId].removeStream(localMediaStream)  if localMediaStream?
						delete peerBroadcastStreamStatus[peerId]
						peerChannel.send(JSON.stringify {action:'cancelled-stream'})

				when 'cancelled-stream'
					destroyPeerStream(peerId)

				when 'snap'
					snapElements[peerId] ?= $("<img>").data('peerId', peerId).addClass('theirs').appendTo($body)
					snapElements[peerId].attr("src", data.dataURI)	 if snapElements[peerId]?
	)

	.on("peer:connect", (peerConnection, peerId, data, monitor) ->
		peerConnections[peerId] = peerConnection

		peerConnection.onaddstream = (event) ->
			streamMedia = media(event.stream)
			streamElement = $(streamMedia.render(document.body)).data('peerId', peerId).addClass('theirs')
			streamElements[peerId] = streamElement
			destroyPeerSnap(peerId)

			#event.stream.onended = -> destroyPeerStream(peerId)

		#peerConnection.onremovestream = (event) -> destroyPeerStream(peerId)
  	)

	.on("peer:leave", (peerId) ->
		destroyPeer(peerId)
	)


localMedia.once('capture', (stream) ->
	localMediaStream = stream
)

$body.on("click", "img.theirs, video.theirs", ->
	peerId = $(@).data('peerId')
	peerChannel = peerChannels[peerId]
	if streamElements[peerId]?
		action = 'cancel-stream'
	else
		action = 'request-stream'
	peerChannel.send(JSON.stringify {action})
)
