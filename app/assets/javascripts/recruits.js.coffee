$(document).ready ->
  # hide alert bubble
  $('.interaction-form.phone-call form, .interaction-form.place-call form').bind('ajax:before', (e) ->
    $('.interaction-status .redalert, .interaction-status .bluenotice').slideUp()
    $('.interaction-status .refresh-needed').slideDown()
  )
