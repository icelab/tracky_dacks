module RackyDacks
  module Jobs
    class Pageview
      include SuckerPunch::Job

      def perform(tracker, params = {})
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
