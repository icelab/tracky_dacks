require "tracky_dacks/handlers/ga"

module TrackyDacks
  module Handlers
    class Event < GA
      def call(params = {})
        hit = tracker.build_event(
          document_location: params["location"],
          document_title: params["title"],
          document_path: params["path"],
          referrer: params["referrer"],
          category: params["category"],
          action: params["action"],
          label: params["label"],
        )
        add_custom_dimensions(hit, params)
        add_custom_metrics(hit, params)
        hit.track!
      end
    end
  end
end
