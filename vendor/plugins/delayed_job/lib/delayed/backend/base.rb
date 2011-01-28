module Delayed
  module Backend
    module Base
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Add a job to the queue
        def enqueue(*args)
          options = {
            :priority => Delayed::Worker.default_priority
          }.merge!(args.extract_options!)

          options[:payload_object] ||= args.shift

          if args.size > 0
            warn "[DEPRECATION] Passing multiple arguments to `#enqueue` is deprecated. Pass a hash with :priority and :run_at."
            options[:priority] = args.first || options[:priority]
            options[:run_at]   = args[1]
          end

          unless options[:payload_object].respond_to?(:perform)
            raise ArgumentError, 'Cannot enqueue items which do not respond to perform'
          end

          self.create(options).tap do |job|
            job.hook(:enqueue)
          end
        end

        def reserve(worker, max_run_time = Worker.max_run_time)
          # We get up to 5 jobs from the db. In case we cannot get exclusive access to a job we try the next.
          # this leads to a more even distribution of jobs across the worker processes
          find_available(worker.name, 5, max_run_time).detect do |job|
            job.lock_exclusively!(max_run_time, worker.name)
          end
        end

        # Hook method that is called before a new worker is forked
        def before_fork
        end

        # Hook method that is called after a new worker is forked
        def after_fork
        end

        def work_off(num = 100)
          warn "[DEPRECATION] `Delayed::Job.work_off` is deprecated. Use `Delayed::Worker.new.work_off instead."
          Delayed::Worker.new.work_off(num)
        end
      end

      def failed?
        failed_at
      end
      alias_method :failed, :failed?

      ParseObjectFromYaml = /\!ruby\/\w+\:([^\s]+)/

      def name
        @name ||= payload_object.respond_to?(:display_name) ?
                    payload_object.display_name :
                    payload_object.class.name
      rescue DeserializationError
        ParseObjectFromYaml.match(handler)[1]
      end

      def payload_object=(object)
        @payload_object = object
        self.handler = object.to_yaml
      end

      def payload_object
        @payload_object ||= YAML.load(self.handler)
      rescue TypeError, LoadError, NameError, ArgumentError => e
        raise DeserializationError,
          "Job failed to load: #{e.message}. Handler: #{handler.inspect}"
      end

      def invoke_job
        hook :before
        payload_object.perform
        hook :success
      rescue Exception => e
        hook :error, e
        raise e
      ensure
        hook :after
      end

      # Unlock this job (note: not saved to DB)
      def unlock
        self.locked_at    = nil
        self.locked_by    = nil
      end

      def hook(name, *args)
        if payload_object.respond_to?(name)
          method = payload_object.method(name)
          method.arity == 0 ? method.call : method.call(self, *args)
        end
      rescue DeserializationError
        # do nothing
      end

      def reschedule_at
        payload_object.respond_to?(:reschedule_at) ?
          payload_object.reschedule_at(self.class.db_time_now, attempts) :
          self.class.db_time_now + (attempts ** 4) + 5
      end
      
      def max_attempts
        payload_object.max_attempts if payload_object.respond_to?(:max_attempts)
      end
      
    protected

      def set_default_run_at
        self.run_at ||= self.class.db_time_now
      end
    end
  end
end
