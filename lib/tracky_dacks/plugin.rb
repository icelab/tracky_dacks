require "base64"
require "tracky_dacks/handlers/event"
require "tracky_dacks/handlers/pageview"
require "tracky_dacks/handlers/social"
require "tracky_dacks/job"

module TrackyDacks
  module Plugin
    IMAGE_PATH = File.join(__dir__, "..", "..", "public", "image.png").freeze

    DEFAULT_HANDLERS = {
      event:    Handlers::Event,
      pageview: Handlers::Pageview,
      social:   Handlers::Social,
    }.freeze

    def self.load_dependencies(app, *)
      app.plugin :sinatra_helpers
    end

    def self.configure(app, runner: Job.method(:perform_async), handlers: DEFAULT_HANDLERS, handler_options: {}, skip_tracking_if: nil)
      plugin_opts = app.opts[:tracky_dacks] = {}

      plugin_opts[:runner] = runner
      plugin_opts[:handlers] = handlers
      plugin_opts[:handler_options] = handler_options
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

              roda_class.opts[:tracky_dacks][:runner].(
                handler,
                params.merge("referrer" => referrer)
              ) unless skip_tracking

              if format == "png"
                send_file IMAGE_PATH, disposition: "inline"
              elsif params["target"]
                status_code = Integer(params.fetch("redirect", 302))
                redirect params["target"], status_code
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
