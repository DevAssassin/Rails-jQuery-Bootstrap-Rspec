(($) ->
  $.fn.popdown = (method, options) ->

    methods =
      init: ->
        this.each ->
          button = $(this)
          popdown = button.closest('.popdown').find('div.popdown-body')


          button.find('a').bind 'click.popdown', (e) ->
            e.preventDefault()

          button.bind 'click.popdown', ->
            if button.hasClass('active')
              methods.close(button)
            else
              popdown.addClass('active')
              button.addClass('active')

          popdown.find('.cancel').bind 'click.popdown', (e) ->
            e.preventDefault()
            methods.close(button)
      close: (el) ->
        el ||= this
        el.closest('.popdown').find('div.popdown-body').removeClass('active')
        el.removeClass('active')

    if methods[method]
      methods[method].apply this, Array.prototype.slice.call(arguments, 1)
    else if typeof method == 'object' || !method
      methods.init.apply this, arguments
    else
      $.error("Method #{method} does not exist in jQuery.popdown")

)(jQuery)
