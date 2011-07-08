/* DO NOT MODIFY. This file was compiled Thu, 07 Jul 2011 16:02:53 GMT from
 * /Users/james/Programming/projects/HackerAcademy/app/scripts/application.coffee
 */

(function() {
  var hideAllMessages, hideMessage, myMessages, showMessage, timeouts;
  myMessages = ['info', 'error'];
  timeouts = {};
  hideAllMessages = function() {
    var msg, msgHeight, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = myMessages.length; _i < _len; _i++) {
      msg = myMessages[_i];
      msgHeight = $('.' + msg).outerHeight();
      _results.push($('.' + msg).css('top', -msgHeight).css('display', 'block'));
    }
    return _results;
  };
  hideMessage = function(type) {
    return $('.' + type).animate({
      top: -$('.' + type).outerHeight()
    }, 500);
  };
  showMessage = function(type) {
    return $('.' + type).animate({
      top: 0
    }, {
      complete: function() {
        return timeouts[type] = setTimeout((function() {
          return hideMessage(type);
        }), 4000);
      },
      duration: 500
    });
  };
  $(document).ready(function() {
    var type, _i, _len;
    hideAllMessages();
    for (_i = 0, _len = myMessages.length; _i < _len; _i++) {
      type = myMessages[_i];
      showMessage(type);
    }
    return $('.message').click(function() {
      var msgType;
      msgType = $(this).attr('class').match(new RegExp(myMessages.join('|')));
      clearTimeout(timeouts[msgType[0]]);
      return $(this).animate({
        top: -$(this).outerHeight()
      }, 500);
    });
  });
}).call(this);
