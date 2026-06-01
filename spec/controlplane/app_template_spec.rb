# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Control Plane app template" do
  let(:template_path) { Rails.root.join(".controlplane/templates/app.yml") }
  let(:documents) { YAML.safe_load_stream(template_path.read, aliases: true) }
  let(:gvc) { documents.find { |document| document["kind"] == "gvc" } }
  let(:env) { gvc.dig("spec", "env").index_by { _1.fetch("name") } }

  it "exposes Gumroad obfuscation keys from app secrets" do
    expect(env.dig("OBFUSCATE_IDS_CIPHER_KEY", "value")).to eq(
      "cpln://secret/{{APP_SECRETS}}.OBFUSCATE_IDS_CIPHER_KEY"
    )
    expect(env.dig("OBFUSCATE_IDS_NUMERIC_CIPHER_KEY", "value")).to eq(
      "cpln://secret/{{APP_SECRETS}}.OBFUSCATE_IDS_NUMERIC_CIPHER_KEY"
    )
  end
end
