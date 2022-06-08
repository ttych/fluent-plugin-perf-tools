# frozen_string_literal: true

module Fluent
  module Plugin
    module PerfTools
      # base class for all perf-tools command
      #  provides common behavior for all command
      class Base
        DEFAULT_INTERVAL = 30
        DEFAULT_COMMAND_ARGS = ""
        DEFAULT_TIME_KEY = "TIME"

        class << self
          attr_reader :command, :discard_regexp, :location

          def set_command(command)
            @command = command
          end

          def set_discard_regexp(regexp)
            @discard_regexp = regexp
          end

          def set_location(location)
            @location = location
          end

          def time_key
            @time_key ||= DEFAULT_TIME_KEY
          end

          def set_time_key(key)
            @time_key = key
          end

          def command_path
            File.expand_path(File.join(File.expand_path(__dir__), "../../../../perf-tools/#{location}/#{command}"))
          end
        end

        attr_reader :command_args, :interval, :time_key

        def initialize(command_args:, interval:)
          @command_args = command_args || DEFAULT_COMMAND_ARGS
          @interval = interval || DEFAULT_INTERVAL
          @time_key = DEFAULT_TIME_KEY
        end

        def stream
          headers = nil
          IO.popen("sudo #{command_path} #{command_args} #{interval}").each do |line|
            next if discard_regexp && line.match(discard_regexp)

            unless headers
              headers = line.split
              next
            end

            record = headers.zip(line.split).to_h
            time = parse_time(record)

            yield time, record
          end
        end

        def parse_time(record)
          if time_key && record.respond_to?(:has_key?) && record.key?(time_key)
            Fluent::EventTime.from_time(Time.parse(record[time_key]))
          else
            Fluent::EventTime.now
          end
        end

        def command_path
          self.class.command_path
        end

        def discard_regexp
          self.class.discard_regexp
        end
      end
    end
  end
end
