module HelperMethods
  # If you do something that triggers a confirm, do it inside an accept_js_confirm or reject_js_confirm block
  def accept_js_confirm
    yield
    accept_alert
  end

  # If you do something that triggers a confirm, do it inside an accept_js_confirm or reject_js_confirm block
  def reject_js_confirm
    yield
    reject_alert
  end

  def accept_alert
    page.driver.browser.switch_to.alert.accept
  end

  def reject_alert
    page.driver.browser.switch_to.alert.dismiss
  end

  def make_visible(selector)
    page.execute_script('$(".interaction-widget .interaction .meta a").css("visibility", "visible")')
    page.execute_script("$('#{selector}').css('visibility', 'visible')")
  end

end

RSpec.configuration.include HelperMethods, :type => :request
