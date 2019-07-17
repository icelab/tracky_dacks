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
          campaign_name: params["campaign_name"],
          campaign_source: params["campaign_source"] || params["referrer"],
          campaign_medium: params["campaign_medium"],
          campaign_keyword: params["campaign_keyword"],
          campaign_content: params["campaign_content"],
          campaign_id: params["campaign_id"],
          user_agent: params["user_agent"],
        )
      end
    end
  end
end
