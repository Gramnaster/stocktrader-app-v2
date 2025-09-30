class ApplicationMailer < ActionMailer::Base
  default from: ENV["GMAIL_USERNAME"] || "noreply@stocktrader.com"
  layout "mailer"
end
