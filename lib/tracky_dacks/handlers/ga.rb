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

      def add_custom_dimensions(hit, params)
        params.select {|param|
          param.start_with? "cd"
        }.each do |param, value|
          dimension_index = param.gsub(/\Acd/, "")
          hit.add_custom_dimension(
            dimension_index,
            value
          )
        end
      end

      def add_custom_metrics(hit, params)
        params.select {|param|
          param.start_with? "cm"
        }.each do |param, value|
          metric_index = param.gsub(/\Acm/, "")
          hit.add_custom_metric(
            metric_index,
            value
          )
        end
      end
    end
  end
end
