hide_bubble_form = ->
  $('.bubble-form, .bubble-overlay').hide()

bubble_autocomplete = ($input) ->
  $input.autocomplete
    source: $input.data('tags')
    select: ->
      $input.closest('form').submit()
      hide_bubble_form()
    minLength: 0
    delay: 0

update_autocomplete = ($input) ->
  if url = $input.data('url')
    $.get url, (data) -> $input.autocomplete('option','source',data)

update_chosen = ($input) ->
  if url = $input.data('url')
    $.get url, (data) ->
      options = data.map (i) ->
        "<option value=\"#{i.id}\">#{i.name}</option>"
      $input.html('<option value=""></option>'+options.join("\n")).trigger('liszt:update')

$('.bubble a[data-shows]').live 'click', (e) ->
  e.preventDefault()
  $to_show = $($(this).data('shows'))
  $form = $to_show.show().children('form')
  $input = $form.find('.bubble-input')
  $input.val('').trigger('liszt:updated').focus() unless $input.is('#person_status')
  $('body').prepend('<div class="bubble-overlay"></div>')
  $form.submit -> hide_bubble_form()

$('.bubble-overlay').live 'click', hide_bubble_form

$('.bubble-form .cancel a').live 'click', hide_bubble_form

$('.bubble a[data-method="delete"]').live 'ajax:success', ->
  $(this).parent('.bubble').fadeOut().remove()

$('.new-tag form').live 'ajax:success', ->
  $input = $(this).find('.bubble-input')
  return if $input.val() == ''
  $bubble = $('#tag-bubble-template').tmpl({tag: $input.val()})
  $('.bubble-section.tags .bubble:last').before($bubble)
  update_autocomplete($input)

$('.tags a[data-method="delete"]').live 'ajax:success', ->
  update_autocomplete($('.new-tag .bubble-input'))

$('.assign-watcher form').live 'ajax:success', ->
  $input = $('.assign-watcher .bubble-input')
  return if $.trim($input.val()) == ''
  $bubble = $('#watcher-bubble-template').tmpl
    watcher_id: $input.val(),
    watcher_name: $input.children('option:selected').text()
  $('.bubble-section.watchers .bubble:last').before($bubble)
  update_chosen($input)

$('.watchers a[data-method="delete"]').live 'ajax:success', ->
  update_chosen($('.assign-watcher .bubble-input'))

$('.assign-board form').live 'ajax:success', ->
  $input = $('.assign-board .bubble-input')
  return if $.trim($input.val()) == ''
  $bubble = $('#board-bubble-template').tmpl
    board_id: $input.val(),
    board_name: $input.children('option:selected').text()
  $('.bubble-section.recruit-boards .bubble:last').before($bubble)
  update_chosen($input)

$('.recruit-boards a[data-method="delete"]').live 'ajax:success', ->
  update_chosen($('.assign-board .bubble-input'))

$('.update-status form').live 'ajax:success', ->
  $('.bubble.status a').html($('.update-status .bubble-input').val()+' &#x25BE;')

$(document).ready ->
  bubble_autocomplete($('.new-tag .bubble-input'))
  $('.assign-watcher .bubble-input').chosen()
  $('.assign-board .bubble-input').chosen()
