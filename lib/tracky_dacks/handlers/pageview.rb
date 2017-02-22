require "tracky_dacks/handlers/ga"

module TrackyDacks
  module Handlers
    class Pageview < GA
      def call(params = {})
        tracker.pageview(
          document_location: params["location"],
          document_title: params["title"],
          document_path: params["path"],
          referrer: params["referrer"],
          campaign_id: params["campaign_id"],
        )
      end
    end
  end
end
