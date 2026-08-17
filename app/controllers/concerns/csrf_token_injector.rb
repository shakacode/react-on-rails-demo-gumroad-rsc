# frozen_string_literal: true

module CsrfTokenInjector
  extend ActiveSupport::Concern

  TOKEN_PLACEHOLDER = "_CROSS_SITE_REQUEST_FORGERY_PROTECTION_TOKEN__"

  SAFE_INSERTION_SELECTOR = /(<meta\s+name=["']csrf-token["']\s+content=["'])#{Regexp.escape(TOKEN_PLACEHOLDER)}(["'])/i

  def rewrite_csrf_token(html, token)
    return html unless html
    html.gsub(SAFE_INSERTION_SELECTOR) { "#{$1}#{token}#{$2}" }
  end

  included do
    after_action :inject_csrf_token
  end

  def inject_csrf_token
    return if @skip_csrf_token_injection
    return unless protect_against_forgery?
    return unless response_body

    original_parts = response_body.is_a?(Array) ? response_body : [response_body]
    rewritten_parts = original_parts.map { |part| rewrite_csrf_token(part, form_authenticity_token) }
    return if rewritten_parts == original_parts

    response.body = rewritten_parts
    response.close
  end
end
