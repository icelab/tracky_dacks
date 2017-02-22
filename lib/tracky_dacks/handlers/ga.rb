require "staccato"

module TrackyDacks
  module Handlers
    class GA
      attr_reader :tracker

      def initialize(tracker_options = {})
        @tracker = build_tracker(tracker_options)
      end

      def call(params = {})
        raise NotImplementedError
      end

      private

      def build_tracker(options)
        options = options.dup

        tracking_id = options.delete(:tracking_id)
        client_id = options.delete(:client_id)

        Staccato.tracker(tracking_id, client_id, options)
      end
    end
  end
end
