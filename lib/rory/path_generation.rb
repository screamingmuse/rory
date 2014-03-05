module Rory
  module PathGeneration
    def path_to(route_name, fields = {})
      if route = @app.routes.detect { |r| r.name == route_name }
        path = route.mask.dup.prepend('/').prepend(base_path.to_s)
        fields.each do |key, value|
          path.gsub!(/\:#{key}/, value.to_s)
        end
        path
      end
    end
  end
end