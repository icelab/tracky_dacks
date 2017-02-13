require "racky_dacks/jobs/event"
require "racky_dacks/jobs/pageview"
require "racky_dacks/jobs/social"

module RackyDacks
  module Plugin
    HANDLERS = {
      event: Jobs::Event,
      pageview: Jobs::PageView,
      social: Jobs::Social,
    }

    def self.configure(app, tracking_id:, client_id: nil, **tracker_options)
      app.opts[:racky_dacks_tracker] = Staccato.tracker(trackind_id, client_id, **tracker_options)
    end

    module RequestMethods
      get do
        HANDLERS.each do |path, handler|
          on /#{path}\.(\w+)/ do |format|
            handler.perform_async(roda_class.opts[:racky_dacks_tracker], r.params)

            if format == "png"
              image = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=")

              response["Content-Type"] = "image/png"
              response["Content-Disposition"] = "inline"
              response.finish_with_body image
            else
              r.redirect params[:target]
            end
          end
        end
      end
    end
  end
end
