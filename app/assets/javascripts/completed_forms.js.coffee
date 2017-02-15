$(document).ready ->
  # Completed Form list
  (->
    $table = $('#completed-form-list')
    url = $table.data('source')
    totalRecordCount = $table.attr('data-total-record-count')

    dynatable = $table.dynatable(
      table:
        defaultColumnIdStyle: 'underscore'
        headRowClass: 'sortable-head'
        rowFilter: (rowIndex, record) ->
          $('<tr></tr>',
            id: 'completed-form-row-' + record.form_group_thread_id
            'data-record-id': record.form_group_thread_id
          )
      dataset:
        ajax: true
        ajaxUrl: url
        ajaxOnLoad: true
        ajaxCache: false
        totalRecordCount: totalRecordCount
        perPage: 25
        perPageOptions: [25, 50, 100, 250, 500]
      filters:
        form: (record) ->
          $('<a></a>',
            html: record.form_name
            href: record.form_link
          )
        actions: (record) ->
          $('<a></a>',
            html: 'View completed form'
            href: record.completed_form_link
          )
        # form_group completed_forms filters
        forms: (record) ->
          record.forms.join(', ')
        assignees: (record) ->
          record.assignee_names.join(', ')
      params:
        perPage: 'limit'
        queryRecordCount: 'queried_record_count'
    )
  )()

  (->
    $('#print-completed-form').click ->
      printable = window.open()
      $iframe = $('iframe')
      $iframe.ready ->
        printable.document.write $iframe.contents().find('html').html()
        printable.print()
      false
  )()
