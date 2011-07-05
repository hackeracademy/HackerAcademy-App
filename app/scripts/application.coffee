myMessages = ['info', 'error']
hideAllMessages = ->
  for msg in myMessages
    msgHeight = $('.' + msg).outerHeight()
    $('.' + msg).css('top', -msgHeight).css('display', 'block')
showMessage = (type) ->
  $('.' + type).animate(top: 0, 500)
$(document).ready ->
  hideAllMessages()
  showMessage type for type in myMessages
  $('.message').click ->
    $(this).animate(top: -$(this).outerHeight(), 500)
