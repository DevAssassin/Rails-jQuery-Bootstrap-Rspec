class AuthenticityTokenController < ApplicationController

  def index
    render text: form_authenticity_token
  end

end
