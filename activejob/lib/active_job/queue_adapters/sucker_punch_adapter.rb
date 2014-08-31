require 'sucker_punch'

module ActiveJob
  module QueueAdapters
    class SuckerPunchAdapter
      class << self
        def enqueue(job, *args)
          JobWrapper.new.async.perform job, *args
        end

        def enqueue_at(job, timestamp, *args)
          delay = timestamp - Time.current.to_f
          JobWrapper.new.async.later delay, job, *args
        end
      end

      class JobWrapper
        include SuckerPunch::Job

        def perform(job, *args)
          job.new.execute(*args)
        end

        def later(delay, job, *args)
          after(delay) { perform(job, *args) }
        end
      end
    end
  end
end
