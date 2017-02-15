module ReportsHelper

  def report_user_filter_pulldown
    options = [
      ["All Reports", ""],
      ["My Reports", current_user.id]
    ]

    current_scope.users.each do |u|
      options << ["#{u.name}'s Reports", u.id] unless u.id == current_user.id
    end

    select_tag "user_filter", options_for_select(options), :class => "report-user-filter"
  end

  def reports_form(report, &block)
    if report.new_record
      semantic_form_for(report, :url => reports_path, &block)
    else
      semantic_form_for(report, :url => report_path(report), &block)
    end
  end
end
