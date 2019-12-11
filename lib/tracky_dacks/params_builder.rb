require "uri"

module TrackyDacks
  class ParamsBuilder
    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    def build
      request_params = params.merge(expanded_params)

      infered_params = infer_params(request_params)

      request_params.merge(infered_params)
    end

    private

    def expanded_params
      {
        "action"           => params["a"],
        "campaign_content" => params["cc"],
        "campaign_id"      => params["ci"],
        "campaign_keyword" => params["ck"],
        "campaign_medium"  => params["cm"],
        "campaign_name"    => params["cn"],
        "campaign_source"  => params["cs"],
        "category"         => params["c"],
        "label"            => params["la"],
        "location"         => params["l"],
        "network"          => params["n"],
        "path"             => params["p"],
        "redirect"         => params["r"],
        "target"           => params["t"],
        "title"            => params["ti"],
      }.compact
    end

    def infer_params(request_params)
      result = {}

      # Use target for the location param if no location is specified.
      unless request_params["location"]
        result["location"] = request_params["target"]
      end

      # Infer path from target unless path is specified.
      unless request_params["path"]
        begin
          result["path"] = URI.parse(request_params["target"]).path
        rescue StandardError => e
          nil
        end
      end

      result
    end
  end
end
