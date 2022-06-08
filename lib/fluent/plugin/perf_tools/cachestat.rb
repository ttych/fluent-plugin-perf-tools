# frozen_string_literal: true

require_relative "base"

module Fluent
  module Plugin
    module PerfTools
      class Cachestat < Base
        set_command "cachestat"
        set_location "fs"
        set_discard_regexp /^Counting cache functions...|^Ending tracing.../
      end

      Command.reference(Cachestat)
    end
  end
end
