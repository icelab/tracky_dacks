require "base64"
require "tracky_dacks/handlers/event"
require "tracky_dacks/handlers/pageview"
require "tracky_dacks/handlers/social"
require "tracky_dacks/job"
require "tracky_dacks/params_builder"

module TrackyDacks
  module Plugin
    IMAGE_PATH = File.join(__dir__, "..", "..", "public", "image.png").freeze

    DEFAULT_HANDLERS = {
      event:    Handlers::Event,
      e:        Handlers::Event,
      pageview: Handlers::Pageview,
      p:        Handlers::Pageview,
      social:   Handlers::Social,
      s:        Handlers::Social
    }.freeze

    def self.load_dependencies(app, *)
      app.plugin :sinatra_helpers
    end

    def self.configure(app, runner: Job.method(:perform_async), handlers: DEFAULT_HANDLERS, handler_options: {}, params_options: {}, skip_tracking_if: nil)
      plugin_opts = app.opts[:tracky_dacks] = {}

      plugin_opts[:runner] = runner
      plugin_opts[:handlers] = handlers
      plugin_opts[:handler_options] = handler_options
      plugin_opts[:params_options] = params_options
      plugin_opts[:skip_tracking_if] = skip_tracking_if
    end

    module RequestMethods
      def tracky_dacks_routes(**handler_options)
        on method: ['GET', 'HEAD'] do
          roda_class.opts[:tracky_dacks][:handlers].each_pair do |key, handler_class|
            on /#{key}\.?(\w+)?/ do |format|
              handler = handler_class.new(roda_class.opts[:tracky_dacks][:handler_options].merge(handler_options))

              skip_tracking =
                if roda_class.opts[:tracky_dacks][:skip_tracking_if]
                  roda_class.opts[:tracky_dacks][:skip_tracking_if].call(self)
                else
                  false
                end

              request_params = ParamsBuilder.build(params, roda_class.opts[:tracky_dacks][:params_options])

              additional_params = {"referrer" => referrer, "user_agent" => user_agent}.compact

              roda_class.opts[:tracky_dacks][:runner].(
                handler,
                request_params.merge(additional_params)
              ) unless skip_tracking

              if format == "png"
                send_file IMAGE_PATH, disposition: "inline"
              elsif request_params["target"]
                status_code = Integer(request_params.fetch("redirect", 302))
                redirect request_params["target"], status_code
              else
                halt [200, {
                  "Content-Type" => "text/html",
                  "Access-Control-Allow-Origin" => "*"
                  }, []]
              end
            end
          end
        end
      end
    end
  end
end
