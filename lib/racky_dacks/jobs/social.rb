module RackyDacks
  module Jobs
    class Social
      include SuckerPunch::Job

      def perform(tracker, params = {})
        tracker.social(
          document_location: params[:location],
          document_title: params[:title],
          document_path: params[:path],
          action: params[:social_action],
          network: params[:network],
          target: target
        )
      end
    end
  end
end
