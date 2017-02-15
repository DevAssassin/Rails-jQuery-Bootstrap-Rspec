$(document).ready ->
  $('.alertbox a.dismiss').click ->
    $(this).closest('.alertbox').slideUp(300)

