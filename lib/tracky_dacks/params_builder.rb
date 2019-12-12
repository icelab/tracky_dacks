require "uri"

module TrackyDacks
  class ParamsBuilder
    def self.build(params, options = {})
      request_params = options[:enable_truncation] ? params.merge(expand_truncated(params)) : params

      if Array(options[:infer]).any?
        request_params = request_params.merge(infer_params(Array(options[:infer]), request_params))
      end

      request_params
    end

    def self.expand_truncated(params)
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
      }.reject { |_,v| v.nil? }
    end

    def self.infer_params(inferred_params_list, params)
      result = {}

      if inferred_params_list.include?(:location)
        result["location"] = params["target"] unless params["location"]
      end

      if inferred_params_list.include?(:path)
        begin
          result["path"] = URI.parse(params["target"]).path unless params["path"]
        rescue StandardError
        end
      end

      result
    end
  end
end
