require 'delegate'

module Rory
  # TODO: add some specs directly around this class; 
  # at the moment, it's only tested via controller_spec
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

    # TODO: see previous TODO
    # def []=(key)
    # end

    private

    # TODO: Make this recursive
    def convert_hash(hash)
      hash.each_with_object({}) do |(key, value), hash|
        new_key = convert_key(key)
        hash[new_key] = value
      end
    end

    def convert_key(key)
      case key
      when Symbol ; key.to_s
      else        ; key
      end
    end
  end
end
