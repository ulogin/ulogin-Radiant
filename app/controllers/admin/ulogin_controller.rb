class Admin::UloginController < ApplicationController
  # без логина
  no_login_required
  # не требует токена аутентификации
  skip_before_filter :verify_authenticity_token

  # метод логин
  def login
    # если пост запрос
    if request.post?
      # вызываем функцию, котороая будет разбирать ответ
      login_parse_request(params)
    else
      # если не пост запрос, то перейдем на страницу авторизации
      redirect_to admin_pages_url
    end
  end

  private

  # Функция разбирает ответ c ulogin и авторизирует профиль на сайте
  def login_parse_request(params)
    # если не nil
    if params[:token]
      # формируем uri
      uri   = URI('http://ulogin.ru/token.php?token=' + params[:token] +  '&host=' + request.host)
      # получаем файл
      s     = Net::HTTP.get(uri)
      # докодируем из JSON вида
      user  = ActiveSupport::JSON.decode(s)
      # если не nil
      if user['uid']
        # смотрим есть ли в базе наш юзер
        newuser = User.find_by_login(user['email'])
        # если nil, т.е юзера нет
        unless newuser
          # формируем пароль
          pass = getPassword
          # создаем юзера
          newuser = User.new(:name => user['first_name'], :login => user['email'], :password => pass, :password_confirmation => pass, :email => user['email'])
          # записываем в базу
          newuser.save
        end

        # сохраняем в переменную
        self.current_user = newuser
        # если не nil
        if current_user
          # есть не nil
          if params[:remember_me]
            # запомним
            current_user.remember_me
            # установим куки
            set_session_cookie
          end
          # перейдем на страницу пользователя
          redirect_to (session[:return_to] || welcome_url)
          session[:return_to] = nil
        end
      end
    end
  end

  # Функция генерирует пароль
  def getPassword
    return rand(10 ** 10).to_s
  end

end
