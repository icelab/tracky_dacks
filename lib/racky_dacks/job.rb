require "sucker_punch"

module RackyDacks
  class Job
    include SuckerPunch::Job

    def perform(handler, params)
      handler.(params)
    end
  end
end
