# frozen_string_literal: true

module Fluent
  module Plugin
    module PerfTools
      class Cachestat
        COMMAND = "cachestat"
        DEFAULT_INTERVAL = 30
        DEFAULT_COMMAND_ARGS = "-t"
        EXTRA_INFO_REGEXP = /^Counting cache functions...|^Ending tracing.../
        TIME_KEY = 'TIME'

        def self.command
          COMMAND
        end

        def self.command_path
          File.expand_path(File.join(File.expand_path(__dir__), "../../../../perf-tools/fs/#{COMMAND}"))
        end

        attr_reader :command_args, :interval

        def initialize(command_args:, interval:)
          @command_args = command_args || DEFAULT_COMMAND_ARGS
          @interval = interval || DEFAULT_INTERVAL
        end

        def command_path
          self.class.command_path
        end

        def time_key
          TIME_KEY
        end

        def stream
          headers = nil
          IO.popen("sudo #{command_path} #{command_args} #{interval}").each do |line|
            next if line.match(EXTRA_INFO_REGEXP)

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
          if time_key && record.respond_to?(:has_key?) && record.has_key?(time_key)
            Fluent::EventTime.from_time(Time.parse(record[time_key]))
          else
            Fluent::EventTime.now
          end
        end
      end

      Command.reference(Cachestat)
    end
  end
end
