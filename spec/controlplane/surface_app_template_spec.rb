# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Control Plane isolated surface app template" do
  let(:template_path) { Rails.root.join(".controlplane/templates/surface_app.yml") }
  let(:documents) { YAML.safe_load_stream(template_path.read, aliases: true) }
  let(:gvc) { documents.find { |document| document["kind"] == "gvc" } }
  let(:env) { gvc.dig("spec", "env").index_by { _1.fetch("name") } }

  it "shares only application keys while keeping each surface database isolated" do
    expect(env.dig("SECRET_KEY_BASE", "value")).to eq(
      "cpln://secret/{{SHARED_SECRET_DEMO_APP}}.SECRET_KEY_BASE"
    )
    expect(env.dig("REACT_ON_RAILS_PRO_LICENSE", "value")).to eq(
      "cpln://secret/{{SHARED_SECRET_DEMO_APP}}.REACT_ON_RAILS_PRO_LICENSE"
    )
    expect(env.dig("DATABASE_USERNAME", "value")).to eq(
      "cpln://secret/{{APP_NAME}}-mysql.username"
    )
    expect(env.dig("MONGO_DATABASE_USERNAME", "value")).to eq(
      "cpln://secret/{{APP_NAME}}-mongo.username"
    )
  end
end
