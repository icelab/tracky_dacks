require "tracky_dacks/handlers/ga"

module TrackyDacks
  module Handlers
    class Social < GA
      def call(params = {})
        tracker.social(
          document_location: params["location"],
          document_title: params["title"],
          document_path: params["path"],
          referrer: params["referrer"],
          action: params["action"],
          network: params["network"],
          target: params["target"],
        )
      end
    end
  end
end
