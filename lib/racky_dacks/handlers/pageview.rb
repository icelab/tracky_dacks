require "racky_dacks/handlers/ga"

module RackyDacks
  module Handlers
    class Pageview < GA
      def call(params = {})
        tracker.pageview(
          document_location: params[:location],
          document_title: params[:title],
          document_path: params[:path],
          campaign_id: params[:campaign_id],
        )
      end
    end
  end
end
