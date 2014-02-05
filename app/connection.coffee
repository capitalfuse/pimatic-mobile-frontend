

$(document).on "pagebeforecreate", ->
  if pimatic.inited then return
  pimatic.inited = yes

  pimatic.socket = io.connect("/", 
    'connect timeout': 20000
    'reconnection delay': 500
    'reconnection limit': 2000 # the max delay
    'max reconnection attempts': Infinity
  )


  pimatic.socket.on 'log', (entry) -> 
    if entry.level is 'error' 
      pimatic.errorCount++
    pimatic.showToast entry.msg
    #console.log entry

  pimatic.socket.on 'connect', ->
    pimatic.loading "socket", "hide"
    if window.applicationCache?
      try
        window.applicationCache.update()
      catch e
        console.log e

  pimatic.socket.on 'connecting', ->
    #console.log "connecting"
    pimatic.loading "socket", "show",
      text: __("connecting")

  ###
    unused socket events:
  ###

  # pimatic.socket.on 'connect_failed', ->
  #   console.log "connect_failed"

  # pimatic.socket.on 'reconnect_failed', ->
  #   console.log "reconnect_failed"

  # pimatic.socket.on 'reconnect', ->
  #   console.log "reconnect"

  # pimatic.socket.on 'reconnecting', ->
  #   console.log "reconnecting"

  pimatic.socket.on 'disconnect', ->
    #console.log "disconnect"
    pimatic.loading "socket", "show",
      text: __("connection lost, retying")

  onConnectionError = ->
    pimatic.loading "socket", "show",
      text: __("could not connect, retying")
      textVisible: true
      textonly: false
    setTimeout ->
      pimatic.socket.socket.connect()
    , 2000

  pimatic.socket.on 'error', onConnectionError
  pimatic.socket.on 'connect_error', onConnectionError