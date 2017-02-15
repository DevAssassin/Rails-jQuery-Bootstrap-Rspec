require 'loofah/helpers'
module ApplicationHelper
  include ActionView::Helpers::TagHelper
  include Loofah::Helpers

  def current_account
    @__current_account ||= if Account === current_scope
      current_scope
    # TODO: Make this part less ugly while retaining proper scoped security
    elsif Program === current_scope
      current_program.try(:account)
    elsif auth_token
      Person.from_auth_token(auth_token).account
    elsif params[:form_id] && (the_form = Form.find(params[:form_id])) && the_form.public
      the_form.account
    end
  end

  def current_program
    @__current_program ||= if Program === current_scope
      current_scope
    elsif params[:program_id]
      current_account.programs.find(params[:program_id])
    end
  end

  def current_scope
    @__current_scope ||= if session[:scope_id] && session[:scope_type]
      case session[:scope_type]
      when "Account"
        current_user.find_scoped_accounts(session[:scope_id]) if current_user
      when "Program"
        current_user.find_scoped_programs(session[:scope_id]) if current_user
      end
    else
      current_user.try(:default_scope)
    end
  end

  def auth_token
    params[:auth_token] || session[:auth_token]
  end

  def time_tag(time = Time.now, options = {})
    options[:class] ||= "time"
    content_tag(:abbr, time, options.merge(:title => time.utc.iso8601)) if time
  end

  def duration_format(duration)
    dur = duration.to_i || 0

    ChronicDuration.output(dur, :format => :short)
  end

  def email_summary(email)
    email ||= ''
    truncate(CGI.unescapeHTML(Loofah.fragment(email.gsub(/<br ?\/?>/," ")).to_text), :length => 140)
  end

  def named_email(name, email)
    email = email.blank? ? "?" : email

    if name
      "#{name} <#{email}>"
    else
      email
    end
  end

  def named_phone(name, phone)
    phone = phone.blank? ? "?" : phone

    if name
      "#{name} <#{phone}>"
    else
      phone
    end
  end

  def lsanitize(str)
    Loofah::Helpers.sanitize(str).html_safe
  end

  def star_rating(value,user_rated = false)
    value ||= 0
    full_stars = value.floor
    split_star_px = (value - full_stars) * 16
    empty_stars = 5 - value.ceil
    empty_stars = 0 if empty_stars < 0

    star = ''
    star += (content_tag :div,content_tag(:span), :class => "ui-stars-star ui-stars-star-on"+(user_rated ? " user" : ""), :style =>"width: 16px;").to_s * full_stars
    if split_star_px != 0
      star += content_tag(:div, content_tag(:span, "", :style => "margin-left: 0px; "), :class => "ui-stars-star ui-stars-star-on"+(user_rated ? " user" : ""), :style =>"width: #{split_star_px}px;")
      star += content_tag(:div, content_tag(:span, "", :style => "margin-left: -#{split_star_px}px; "), :class => "ui-stars-star ", :style =>"width: #{16 -split_star_px}px;")
    end
    star += (content_tag :div,content_tag(:span), :class => "ui-stars-star", :style =>"width: 16px;").to_s * empty_stars
  end

  def body_column_class(sidebar)
    sidebar ? "two-col" : "one-col"
  end

  def scope_pulldown
    select_tag :scope, grouped_options_for_select(scope_options, "#{current_scope.class.to_s}|#{current_scope.id}")
  end

  def scope_options
    accounts = current_user.accounts
    programs = current_user.programs

    mapper = lambda {|a| [a.name, "#{a.class.to_s}|#{a.id}"]}

    accounts_kv = accounts.map(&mapper)
    programs_kv = programs.map(&mapper)

    return [["Accounts", accounts_kv],["Programs", programs_kv]]
  end

  def twitter_link(handle)
    if handle
      "<a href='http://twitter.com/#{h handle}' target='_blank'>#{h handle}</a>"
    else
      ""
    end.html_safe
  end

  def facebook_link(url)
    if url
      link_to url, url, :target => "_blank"
    else
      ""
    end.html_safe
  end

  def typed_people_path(type)
    case type
    when "all"
      all_people_path
    else
      type.blank? ? people_path : send("#{type}_path")
    end
  end

  def interaction_scope_options
    # Account dashboard options
    if current_scope.is_a?(Account)
      [
        ['Overview', [
          ['Account & Programs', ''],
          ['Account-level only', 'Account'],
          ['Program-level only', 'Program'],
        ]],
        ['Programs', current_account.programs.collect { |p| [p.name, p.id] }]
      ]
    # Program dashboard options
    else
      []
    end
  end

  def global_message
    current_program.recruiting_calendar_items.current.first if current_program
  end

  def calls_remaining(count)
    if count == -1
      'unlimited calls'
    else
      pluralize(count, 'call')
    end
  end

  def hidden_field?(field)
    current_scope.hidden_fields.include?(field)
  end

  def submit_or_cancel(options = {})
    options[:submit] ||= 'Save'
    options[:disable_with] ||= 'Saving...'
    options[:cancel] ||= '#'
    render :template => 'shared/submit_or_cancel', :locals => { :options => options }
  end

  def default_person_query
    {:user_filter => current_user.default_contact_filter}
  end

  def notifications
    if current_user
      Notification.for_user(current_user)
    else
      []
    end
  end

end
