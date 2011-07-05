myMessages = ['info', 'error']
hideAllMessages = ->
  for msg in myMessages
    msgHeight = $('.' + msg).outerHeight()
    $('.' + msg).css('top', -msgHeight)
showMessage = (type) ->
  $('.' + type + '-trigger').click ->
    hideAllMessages()
    $('.' + type).animate(top: 0, 500)
$(document).ready ->
  $('.message').click ->
    $(this).animate(top: -$(this).outerHeight(), 500)
