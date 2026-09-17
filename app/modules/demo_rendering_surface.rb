# frozen_string_literal: true

class DemoRenderingSurface
  SURFACES = %i[legacy next landing].freeze
  ENV_NAME = "GUMROAD_RENDERING_SURFACE"

  class << self
    def current(request:)
      configured_surface || release_surface || host_surface(request.host) || :landing
    end

    private
      def configured_surface
        value = ENV[ENV_NAME]
        return if value.blank?

        value = value.to_sym
        return value if SURFACES.include?(value)

        raise ArgumentError, "#{ENV_NAME} must be one of: #{SURFACES.join(', ')}"
      end

      def release_surface
        release_name = ENV["BRANCH"].to_s
        SURFACES.find { |surface| release_name.end_with?("-#{surface}") }
      end

      def host_surface(host)
        label = host.to_s.split(".").first
        label.to_sym if SURFACES.include?(label&.to_sym)
      end
  end
end
