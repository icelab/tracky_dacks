require "tracky_dacks/handlers/ga"

module TrackyDacks
  module Handlers
    class Social < GA
      def call(params = {})
        hit = tracker.build_social(
          document_location: params["location"],
          document_title: params["title"],
          document_path: params["path"],
          referrer: params["referrer"],
          action: params["action"],
          network: params["network"],
          target: params["target"],
        )
        add_custom_dimensions(hit, params)
        add_custom_metrics(hit, params)
        hit.track!
      end
    end
  end
end
