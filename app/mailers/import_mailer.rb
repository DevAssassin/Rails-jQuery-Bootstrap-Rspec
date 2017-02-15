class ImportMailer < ActionMailer::Base
  default from: "admin@scoutforce.com"

  def initiated(import)
    @import = import

    mail to: import.user.email, subject: 'Import Initiated'
  end

  def completed(import)
    @import = import

    mail to: import.user.email, subject: 'Import Complete'
  end
end
