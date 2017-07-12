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

    def self.configure(app, runner: Job.method(:perform_async), handlers: DEFAULT_HANDLERS, handler_options: {})
      plugin_opts = app.opts[:tracky_dacks] = {}

      plugin_opts[:runner] = runner
      plugin_opts[:handlers] = handlers
      plugin_opts[:handler_options] = handler_options
    end

    module RequestMethods
      def tracky_dacks_routes(**handler_options)
        get do
          roda_class.opts[:tracky_dacks][:handlers].each_pair do |key, handler_class|
            on /#{key}\.?(\w+)?/ do |format|
              handler = handler_class.new(roda_class.opts[:tracky_dacks][:handler_options].merge(handler_options))

              roda_class.opts[:tracky_dacks][:runner].(
                handler,
                params.merge("referrer": referrer)
              )

              if format == "png"
                send_file IMAGE_PATH, disposition: "inline"
              else
                status_code = Integer(params.fetch("redirect", 302))
                redirect params["target"], status_code
              end
            end
          end
        end
      end
    end
  end
end
