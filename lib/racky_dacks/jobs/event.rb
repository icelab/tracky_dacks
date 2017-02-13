module RackyDacks
  module Jobs
    class Event
      include SuckerPunch::Job

      def perform(tracker, params = {})
        tracker.event(
          document_location: params[:location],
          document_title: params[:title],
          document_path: params[:path],
          category: params[:event_category],
          action: params[:event_action],
          label: params[:event_label]
        )
      end
    end
  end
end
