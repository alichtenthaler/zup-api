# encoding: utf-8
class UserMailer < ZupMailer
  helper :application

  RESTRICT_ACTIONS = {
    notify_report_creation: :report_created,
    notify_report_status_update: :report_changed_status
  }

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user.send_password_recovery_instructions.subject
  #
  def send_password_recovery_instructions(user)
    @user = user
    @token = user.reset_password_token
    mail to: user.email, subject: "Pedido de Recuperação de Senha"
  end

  # Send email to user when it creates a report
  def notify_report_creation(report)
    @report = report
    @user = report.user
    mail to: @user.email, subject: "Recebemos sua solicitação"
  end

  # If the status of a report changes, send e-mail
  def notify_report_status_update(report)
    @report = report
    @user = report.user
    status = report.status.title

    mail to: @user.email, subject: "O status da sua solicitação foi alterado para '#{status}'"
  end
end
