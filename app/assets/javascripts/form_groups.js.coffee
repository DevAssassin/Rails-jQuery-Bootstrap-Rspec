# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('#form-group-list').dynatable(
    unfilters:
      completed: (cell, record) ->
        $cell = $(cell)
        record.sortable_completed = parseInt($cell.text())
        $cell.html()
      updated_at: (cell, record) ->
        new Date($(cell).text())
  )
  $('#form-checkboxes').sortable()
