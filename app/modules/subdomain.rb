# frozen_string_literal: true

module Subdomain
  USERNAME_REGEXP = /[a-z0-9-]+/

  class << self
    def find_seller_by_request(request)
      find_seller_by_hostname(request.host)
    end

    def find_seller_by_hostname(hostname)
      if subdomain_request?(hostname)
        subdomain = ActionDispatch::Http::URL.extract_subdomains(hostname, 1)[0]

        return User.alive.find_by(external_id: subdomain) if /^[0-9]+$/.match?(subdomain)

        # Convert hyphens to underscores before looking up with usernames.
        # Related conversation: https://git.io/JJgBN
        User.alive.find_by(username: subdomain.tr("-", "_"))
      end
    end

    def from_username(username)
      return unless username.present?
      "#{username.tr("_", "-")}.#{creator_root_domain}"
    end

    private
      def subdomain_request?(hostname)
        # request.host never includes a port, including for a local surface root override.
        domain = URI("#{PROTOCOL}://#{creator_root_domain}").host

        # Allows lowercase letters, numbers and hyphens (to support usernames with underscores).
        # Subdomain should contain at least one letter.
        hostname =~ /\A#{USERNAME_REGEXP.source}.#{domain}\z/
      end

      def creator_root_domain
        return ROOT_DOMAIN unless ENV["SHAKAPERF_TWIN_SERVERS"] == "true"
        return ROOT_DOMAIN if Rails.env.production?

        ENV["SHAKAPERF_CREATOR_ROOT_DOMAIN"].presence || ROOT_DOMAIN
      end
  end
end
