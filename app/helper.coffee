# General
# -------

$.ajaxSetup timeout: 20000 #ms

loadingStack = 0
proxied = $.mobile.loading
$.mobile.loading = (args...) ->
  if args[0] is 'show'
    loadingStack++
    proxied.apply(this, args)
  else 
    if loadingStack > 0
      loadingStack--
      if loadingStack is 0
        proxied.apply(this, args)

$(document).ajaxStart ->
  $.mobile.loading "show",
    text: "Loading..."
    textVisible: true
    textonly: false

$(document).ajaxStop ->
  $.mobile.loading "hide"


ajaxShowToast = (data, textStatus, jqXHR) -> 
  showToast (if data.message? then message else 'done')

ajaxAlertFail = (jqXHR, textStatus, errorThrown) ->
  data = null
  try
    data = $.parseJSON jqXHR.responseText
  catch e 
    #ignore error
  message =
    if data?.error?
      data.error
    else if errorThrown? and errorThrown != ""
      message = errorThrown
    else if textStatus is 'error'
      message = 'no connection'
    else
      message = textStatus

  alert __(message)

voiceCallback = (matches) ->
  $.get "/api/speak",
    word: matches
  , (data) ->
    showToast data
    $("#talk").blur()

showToast = 
  if device? and device.showToast?
    device.showToast
  else
    (msg) -> $('#toast').text(msg).toast().toast('show')

__ = (text, args...) -> 
  translated = text
  if locale[text]? then translated = locale[text]
  else console.log 'no translation yet:', text
    
  for a in args
    translated = translated.replace /%s/, a
  return translated
