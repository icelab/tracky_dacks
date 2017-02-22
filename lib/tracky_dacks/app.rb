require "roda"

module TrackyDacks
  class App < Roda
    plugin :tracky_dacks, handler_options: {tracking_id: "abc"}

    route do |r|
      r.tracky_dacks_routes
    end
  end
end
