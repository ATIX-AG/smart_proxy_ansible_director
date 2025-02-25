require 'smart_proxy_pulsible/api'

map "/pulsible" do
  run Proxy::Pulsible::Api
end
