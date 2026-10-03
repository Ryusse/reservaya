class NotificationMailer < ApplicationMailer
  def reservation_created(user, reservation)
    @user = user
    @reservation = reservation
    mail(to: @user.email, subject: "Tu reserva fue creada correctamente")
  end
end