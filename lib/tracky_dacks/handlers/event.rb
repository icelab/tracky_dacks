require "tracky_dacks/handlers/ga"

module TrackyDacks
  module Handlers
    class Event < GA
      def call(params = {})
        tracker.event(
          document_location: params["location"],
          document_title: params["title"],
          document_path: params["path"],
          category: params["category"],
          action: params["action"],
          label: params["label"]
        )
      end
    end
  end
end
