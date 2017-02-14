require "base64"
require "staccato"
require "racky_dacks/handlers/event"
require "racky_dacks/handlers/pageview"
require "racky_dacks/handlers/social"
require "racky_dacks/job"

module RackyDacks
  module Plugin
    IMAGE_DATA = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=").freeze

    DEFAULT_HANDLERS = {
      event:    Handlers::Event,
      pageview: Handlers::Pageview,
      social:   Handlers::Social,
    }.freeze

    def self.configure(app, runner: Job.method(:perform_async), handlers: DEFAULT_HANDLERS, handler_options: {})
      plugin_opts = app.opts[:racky_dacks] = {}

      plugin_opts[:runner] = runner

      plugin_opts[:handlers] = handlers.each_with_object({}) { |(key, handler_class), result|
        result[key] = handler_class.new(handler_options)
      }
    end

    module RequestMethods
      def racky_dacks_routes
        get do
          roda_class.opts[:racky_dacks][:handlers].each_pair do |key, handler|
            on /#{key}\.?(\w+)?/ do |format|
              roda_class.opts[:racky_dacks][:runner].(handler, params)

              if format == "png"
                response["Content-Type"] = "image/png"
                response["Content-Disposition"] = "inline"
                halt response.finish_with_body IMAGE_DATA
              else
                redirect params[:target]
              end
            end
          end
        end
      end
    end
  end
end
