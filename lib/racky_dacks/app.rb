require "roda"

module RackyDacks
  class App < Roda
    plugin :racky_dacks, handler_options: {tracking_id: "abc"}

    route do |r|
      r.racky_dacks_routes
    end
  end
end
