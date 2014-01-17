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
		fps: 0.5
		mime: 'image/jpeg'
		quality: 0.8

signaller = null
peerConnections = {}
peerChannels = {}
peerStreams = {}
peerStreamMedias = {}
peerStreamElements = {}
peerSnapElements = {}
localStream = null
localStreamMedia = null
localStreamVideo = null
peerBroadcastStreamStatus = {}
$body = null

# create a video processing canvas that will capture an update every second
canvas = videoproc(document.body, config.snapOptions)

# capture media and render to the canvas
localStreamMedia = media(constraints: captureConfig("camera max:320x240").toConstraints())
localStreamMedia.render(canvas)
canvas.style.display = "none"
localStreamVideo = localStreamMedia.render(document.body)

# add the processing options
canvas.pipeline.add(grayScaleFilter)

# once the canvas has been updated with the filters applied
# capture the image data from the canvas and send via the data channel
canvas.addEventListener "postprocess", (event) ->
	dataURI = canvas.toDataURL(config.snapOptions.mime, config.snapOptions.quality)
	for own peerId,peerChannel of peerChannels
		if peerBroadcastStreamStatus[peerId] isnt true
			sendMessage(peerId, {action:'snap', dataURI})

signaller = quickconnect(config.signalHost, config.connectionOptions)
$body = $(document.body)

destroyPeerSnap = (peerId) ->
	if peerSnapElements[peerId]?
		peerSnapElements[peerId].remove()
		delete peerSnapElements[peerId]

destroyPeerStream = (peerId) ->
	if peerStreamElements[peerId]?
		peerStreamElements[peerId].remove()
		delete peerStreamElements[peerId]

destroyPeer = (peerId) ->
	destroyPeerSnap(peerId)
	destroyPeerStream(peerId)

	delete peerChannels[peerId]
	delete peerStreams[peerId]
	delete peerStreamMedias[peerId]
	delete peerBroadcastStreamStatus[peerId]

showPeerStream = (peerId) ->
	peerStreamMedias[peerId] ?= media(peerStreams[peerId])
	peerStreamElements[peerId] ?= $(peerStreamMedias[peerId].render(document.body)).data('peerId', peerId).addClass('theirs')
	destroyPeerSnap(peerId)

sendMessage = (peerId, data) ->
	message = JSON.stringify(data)
	console.log('send message', data, 'to', peerId)
	peerChannels[peerId].send(message)


signaller
	.createDataChannel("messages")

	.on("messages:open", (peerChannel, peerId) ->
		peerChannels[peerId] = peerChannel

		peerChannel.onmessage = (event) ->
			data = JSON.parse(event.data or '{}') or {}
			console.log('received message', data, 'from', peerId)

			switch data.action
				when 'request-stream'
					debugger
					if peerBroadcastStreamStatus[peerId]? is false and localStream
						peerConnections[peerId].addStream(localStream)
						peerBroadcastStreamStatus[peerId] = true
						sendMessage(peerId, {action:'sent-stream'})

				when 'cancel-stream'
					if peerBroadcastStreamStatus[peerId] is true
						peerConnections[peerId].removeStream(localStream)  if localStream?
						delete peerBroadcastStreamStatus[peerId]
						sendMessage(peerId, {action:'cancelled-stream'})

				when 'sent-stream'
					setTimeout(
						->
							console.log('RECEIVED STREAM', peerStreams[peerId], event)
							showPeerStream(peerId)
						1000
					)

				when 'cancelled-stream'
					destroyPeerStream(peerId)

				when 'snap'
					if peerSnapElements[peerId]? is false
						peerSnapElements[peerId] = $("<img>").data('peerId', peerId).addClass('theirs').appendTo($body)
					peerSnapElements[peerId].attr("src", data.dataURI)
	)

	.on("peer:connect", (peerConnection, peerId, data, monitor) ->
		peerConnections[peerId] = peerConnection

		peerConnection.onaddstream = (event) ->
			peerStreams[peerId] = event.stream
			showPeerStream(peerId)

			#event.stream.onended = -> destroyPeerStream(peerId)

		#peerConnection.onremovestream = (event) -> destroyPeerStream(peerId)
  	)

	.on("peer:leave", (peerId) ->
		destroyPeer(peerId)
	)


localStreamMedia.once('capture', (stream) ->
	localStream = stream
)

$body.on("click", "img.theirs, video.theirs", ->
	peerId = $(@).data('peerId')
	if peerStreamElements[peerId]?
		action = 'cancel-stream'
	else
		action = 'request-stream'
	sendMessage(peerId, {action})
)
