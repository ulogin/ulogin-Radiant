ActionController::Routing::Routes.draw do |map|
  # добавим маршрут
  map.login 'admin/ulogin', :controller => 'admin/ulogin', :action => 'login'
end