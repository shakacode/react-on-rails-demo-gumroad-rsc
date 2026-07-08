# frozen_string_literal: true

module InertiaPagePayloadHelper
  def serialized_inertia_page_payload
    html = Nokogiri::HTML(response.body)
    script_payload = html.at_css('script[type="application/json"][data-page]')
    return JSON.parse(CGI.unescapeHTML(script_payload.text)) if script_payload

    attribute_payload = html.at_css("[data-page]")&.attribute("data-page")&.value
    expect(attribute_payload).to be_present

    JSON.parse(CGI.unescapeHTML(attribute_payload))
  end
end

RSpec.configure do |config|
  config.include InertiaPagePayloadHelper, type: :controller
end
