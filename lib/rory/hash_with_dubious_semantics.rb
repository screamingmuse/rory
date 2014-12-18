require 'delegate'

module Rory
  # ActiveSupport's HashWithIndifferentAccess put it best:
  #
  # "This class has dubious semantics and we only have it so that people
  # can write params[:key] instead of params[‘key’] and they get the
  # same value for both keys."
  class HashWithDubiousSemantics < SimpleDelegator
    def initialize(hash)
      fail ArgumentError unless hash.is_a?(Hash)
      hash_with_no_symbols = convert_hash(hash)
      super( hash_with_no_symbols )
    end

    def [](key)
      actual_key = convert_key(key)
      __getobj__[actual_key]
    end

    def []=(key, value)
      actual_key = convert_key(key)
      new_value = convert_value(value)
      __getobj__[actual_key] = new_value
    end

    def inspect
      "#<#{self.class.name} @hash=#{super}>"
    end

    private

    def convert_hash(hash)
      return hash if hash.empty?

      hash.each_with_object({}) do |(key, value), converted_hash|
        new_key   = convert_key(key)
        new_value = convert_value(value)

        converted_hash[new_key] = new_value
      end
    end

    def convert_key(key)
      case key
      when Symbol ; key.to_s
      else        ; key
      end
    end

    def convert_value(value)
      case value
      when Hash ; HashWithDubiousSemantics.new(convert_hash(value))
      else      ; value
      end
    end
  end
end
