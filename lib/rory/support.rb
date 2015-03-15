module Rory
  # Support methods for utility functionality such as string modification -
  # could also be accomplished by monkey-patching String class.
  module Support
    module_function

    def camelize(string)
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string = string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end

    def constantize(string)
      camelized = camelize(string)
      camelized.split('::').inject(Object) { |scope, const|
        scope.const_get(const)
      }
    end

    def tokenize(string)
      return nil if string.nil?
      string = string.to_s.gsub(/&/, ' and ').
        gsub(/[ \/]+/, '_').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        downcase
    end

    def require_all_files_in_directory(path)
      Dir[Pathname.new(path).join('**', '*.rb')].each do |file|
        require file
      end
    end

    def encode_as_json(object)
      try_to_hash(object).to_json
    end

    def try_to_hash(object)
      if object.is_a?(Array)
        object.map { |val| try_to_hash(val) }
      elsif object.is_a?(Hash)
        Hash[object.map { |key, val| [key, try_to_hash(val)] }]
      elsif object.respond_to?(:to_hash)
        object.to_hash
      else
        object
      end
    end
  end
end
