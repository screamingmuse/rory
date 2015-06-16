module Rory
  class ParameterFilter
    FILTERED = '[FILTERED]'.freeze

    def initialize(filters = [])
      @filters = filters
    end

    def filter(params)
      compiled_filter.call(params)
    end

    private

    def compiled_filter
      @compiled_filter ||= CompiledFilter.compile(@filters)
    end

    class CompiledFilter
      def self.compile(filters)
        return lambda { |params| params.dup } if filters.empty?

        strings, regexps, blocks = [], [], []

        filters.each do |item|
          case item
            when Regexp
              regexps << item
            else
              strings << item.to_s
          end
        end

        regexps << Regexp.new(strings.join('|'), true) unless strings.empty?
        new regexps, blocks
      end

      attr_reader :regexps, :blocks

      def initialize(regexps, blocks)
        @regexps = regexps
        @blocks  = blocks
      end

      def call(original_params)
        filtered_params = {}

        original_params.each do |key, value|
          if regexps.any? { |r| key =~ r }
            value = FILTERED
          elsif value.is_a?(Hash)
            value = call(value)
          elsif value.is_a?(Array)
            value = value.map { |v| v.is_a?(Hash) ? call(v) : v }
          end

          filtered_params[key] = value
        end

        filtered_params
      end
    end
  end
end
