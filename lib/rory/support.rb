module Rory
  # Support methods for utility functionality such as string modification -
  # could also be accomplished by monkey-patching String class.
  module Support
    module_function

    def camelize(string)
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string = string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end

    def extract_class_name_from_path(path)
      name = File.basename(path).sub(/(.*)\.rb$/, '\1')
      name = camelize(name)
    end

    def autoload_file(path)
      path = File.expand_path(path)
      name = extract_class_name_from_path(path)
      Object.autoload name.to_sym, path
    end

    def autoload_all_files_in_directory(path)
      Dir[Pathname.new(path).join('**', '*.rb')].each do |file|
        Rory::Support.autoload_file file
      end
    end
  end
end
