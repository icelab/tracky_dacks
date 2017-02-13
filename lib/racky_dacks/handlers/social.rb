require "racky_dacks/handlers/ga"

module RackyDacks
  module Handlers
    class Social < GA
      def call(params = {})
        tracker.social(
          document_location: params[:location],
          document_title: params[:title],
          document_path: params[:path],
          action: params[:action],
          network: params[:network],
          target: params[:target],
        )
      end
    end
  end
end
