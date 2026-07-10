# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../scripts/perf/measure_dashboard"

class MeasureDashboardTest < Minitest::Test
  def test_extracts_props_from_inertia_json_script
    html = <<~HTML
      <script data-page="app" type="application/json">
        {"component":"PublicProduct/InertiaDemo","props":{"title":"Tendon Book","products":[1,2,3]}}
      </script>
      <div id="app"></div>
    HTML

    assert_equal(
      { "title" => "Tendon Book", "products" => [1, 2, 3] },
      extract_data_page_props(html)
    )
  end

  def test_keeps_legacy_data_page_attribute_support
    payload = CGI.escapeHTML({ component: "Dashboard", props: { title: "Legacy" } }.to_json)

    assert_equal(
      { "title" => "Legacy" },
      extract_data_page_props(%(<div id="app" data-page="#{payload}"></div>))
    )
  end
end
