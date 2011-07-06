# JS for notification thing from
# http://www.red-team-design.com/wp-content/uploads/2011/07/cool-notification-messages-with-css3-and-jquery-demo.html
myMessages = ['info', 'error']
timeouts = {}
hideAllMessages = ->
  for msg in myMessages
    msgHeight = $('.' + msg).outerHeight()
    $('.' + msg).css('top', -msgHeight).css('display', 'block')
hideMessage = (type) ->
  $('.' + type).animate(top: -$('.' + type).outerHeight(), 500)
showMessage = (type) ->
  $('.' + type).animate(
    {top: 0},
    complete: -> timeouts[type] = setTimeout((-> hideMessage(type)), 4000)
    duration: 500)
$(document).ready ->
  hideAllMessages()
  showMessage type for type in myMessages
  $('.message').click ->
    msgType =  $(this).attr('class').match new RegExp myMessages.join('|')
    clearTimeout timeouts[msgType[0]]
    $(this).animate(top: -$(this).outerHeight(), 500)
