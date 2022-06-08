# frozen_string_literal: true

require "fluent/plugin/input"

require_relative "perf_tools"

module Fluent
  module Plugin
    class InPerfTools < Fluent::Plugin::Input
      PLUGIN_NAME = "perf_tools"
      Fluent::Plugin.register_input(PLUGIN_NAME, self)

      desc "The tag of the event."
      config_param :tag, :string
      desc "Command name"
      config_param :command, :string
      desc "Command args"
      config_param :command_args, :string, default: nil
      desc "Interval"
      config_param :interval, :time, default: 30

      def configure(conf)
        super

        @command = PerfTools::Command.new(command: @command,
                                          command_args: @command_args,
                                          interval: @interval)
      rescue StandardError => e
        log.error e.to_s
        raise Fluent::ConfigError, e
      end

      def start
        super

        @command.stream do |time, record|
          router.emit(tag, time, record)
        end
      end
    end
  end
end
