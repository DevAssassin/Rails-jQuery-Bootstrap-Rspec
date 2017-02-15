disable = ->
  $.each(arguments, ->
    this.prop('disabled', true)
  )

enable = ->
  $.each(arguments, ->
    this.prop('disabled', false)
  )

toggleFormGroupAssignees = (elem, hideFormGroups) ->
  if elem.assigneeIds.is(':disabled') || hideFormGroups
    disable(elem.formGroupAssigneeIds, elem.formGroupId)
    enable(elem.assigneeIds)

    elem.taskAssignees.show()
    elem.formGroup.hide()
    elem.taskNoForm.show()
  else
    enable(elem.formGroupAssigneeIds, elem.formGroupId)
    disable(elem.assigneeIds)

    elem.formGroup.show()
    elem.taskAssignees.hide()
    elem.taskNoForm.hide()

autocompleteUrl = (elem) ->
  url = elem.data('source')
  $program = $('#task_program_id')
  if $program.val()
    # Name it something other than program_id,
    # so we don't screw up the session's current_scope
    url += "?people_program=#{$program.val()}"
  url

autocompletify = (elem) ->
  url = ->
    autocompleteUrl(elem)

  elem.tokenInput( url,
    theme: 'facebook'
    onResult: (results) ->
      tokenResults = ( {id: value._id, name: [value.first_name, value.last_name].join(' ')} for value in results )
      return tokenResults
    prePopulate: eval(elem.data('pre-populate'))
    hintText: "Start typing contact's name"
    noResultsText: "No contacts found"
    preventDuplicates: true
  )

$('#task-filter').live('ajax:complete', (e, data) ->
  response = $.parseJSON(data.responseText).html
  $(this).parents('.task-list').find('.tasks').html(response)
)

$('.task-info').live('click', ->
  $this = $(this)
  $drawer = $this.parents('.task-item').siblings('.task-drawer')
  $arrow = $this.children('.task-arrow')

  if $drawer.is(':visible')
    $arrow.removeClass('visible').html("&#9658;")
  else
    $arrow.addClass('visible').html("&#9660;")

  $drawer.slideToggle()
)


$('#task-list-form').live('ajax:success', (e, data, status, xhr) ->
  $this = $(this)
  updatedTasks = data.tasks

  $.each(updatedTasks, ->
    $span = $('#task-' + this._id)
    if ( data.action_performed == 'complete' )
      $span
        .addClass('completed')
        .removeClass('past-due')
        .removeClass('due-soon')
        .delay(800)
        .slideUp()
    else if ( data.action_performed == 'incomplete' )
      $span
        .removeClass('completed')
        .delay(800)
        .slideUp()
    else if ( data.action_performed == 'delete' )
      if this.errors && !$.isEmptyObject(this.errors)
        str = ''
        str += "<li>#{error.join(', ')}</li>" for name, error of this.errors
        $span.append("<div class='redalert'><ul>#{str}</ul></div>")
      else
        $span
          .slideUp(->
            $(this).remove()
          )
  )
)

$(document).ready ->
  elem =
    taskAssignees:        $('#task-assignees-string')
    assigneeIds:          $('#task_assignee_ids_string')
    taskNoForm:           $('#task-no-form')
    formGroup:            $('#task-form-group')
    formGroupId:          $('#task_form_group_id')
    formGroupAssignments: $('#task-form-group-assignments')
    formGroupAssigneeIds: $('#task-form-group-assignments input.assignee_ids_string')

  $taskAssigneesInput = $('#task_assignee_ids_string, .assignee_ids_string')
  $taskAssigneesInput.each( ->
    autocompletify($(this))
  )

  if elem.formGroupId.val()
    toggleFormGroupAssignees(elem)
  else
    toggleFormGroupAssignees(elem, true)

  $(document).delegate('#task-assign-form-group, #task-assign-no-form', 'click', (e) ->
    toggleFormGroupAssignees(elem)
    e.preventDefault()
  )

  elem.formGroupId.change((e) ->
    $this = $(this)
    prePopulate = elem.assigneeIds.data('pre-populate')
    $.ajax(
      url: $this.data('url')
      method: 'GET'
      data:
        form_group_id: $this.val()
      success: (forms) ->
        html = $()
        $.each(forms, (i) ->
          # TODO: We should be using a template for this since we already have this
          # html duplicated in the new task form
          input = $('<input />'
            id: "task_form_group_assignments_#{this._id}_assignee_ids_string"
            class: "assignee_ids_string"
            type: "text"
            name: "task[form_group_assignments][#{this._id}][assignee_ids_string]"
            'data-source': "/people/token_complete"
          )
          if i == 0
            input.data('pre-populate', prePopulate)
          label = $('<label />'
            for: input.attr('id')
            html: "#{this.name} assignees"
          )
          li = $('<li />'
            class: "string required"
          )
          li.append(label).append(input)
          html = html.add(li)
        )
        elem.formGroupAssignments.html(html)
        elem.formGroupAssignments.find('.assignee_ids_string').each( ->
          autocompletify($(this))
        )
    )
  )
