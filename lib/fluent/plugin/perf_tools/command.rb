# frozen_string_literal: true

module Fluent
  module Plugin
    module PerfTools
      module Command
        class << self
          def commands
            @commands ||= {}
          end

          def reference(klass)
            return unless klass.command
            commands[klass.command] = klass
          end

          def new(command:, command_args:, interval:)
            if commands.has_key? command
              return commands[command].new(command_args: command_args, interval: interval)
            end

            raise Fluent::ConfigError, "perf_tools: #{command} not available"
          end
        end
      end
    end
  end
end

require_relative 'cachestat'
