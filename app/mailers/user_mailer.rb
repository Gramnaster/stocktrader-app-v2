class UserMailer < ApplicationMailer
  def trader_approval_notification(user)
    @user = user
    @app_name = "Stock Trader App"

    mail(
      to: @user.email,
      subject: "Your Trader Account Has Been Approved!"
    )
  end

  def trader_rejection_notification(user)
    @user = user
    @app_name = "Stock Trader App"

    mail(
      to: @user.email,
      subject: "Update on Your Trader Account Application"
    )
  end

  def signup_confirmation(user)
    @user = user
    @app_name = "Stock Trader App"

    mail(
      to: @user.email,
      subject: "Welcome to Stock Trader App - Please Confirm Your Email"
    )
  end

  def admin_new_trader_notification(user, admin_email = nil)
    @user = user
    @app_name = "Stock Trader App"
    @admin_email = admin_email || ENV["ADMIN_EMAIL"] || "admin@stocktrader.com"

    mail(
      to: @admin_email,
      subject: "New Trader Registration Pending Approval"
    )
  end
end
