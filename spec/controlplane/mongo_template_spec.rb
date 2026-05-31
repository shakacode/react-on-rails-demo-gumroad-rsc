# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Control Plane Mongo template" do
  let(:template_path) { Rails.root.join(".controlplane/templates/mongo.yml") }
  let(:documents) { YAML.safe_load_stream(template_path.read, aliases: true) }
  let(:mongo_workload) { documents.find { |document| document["kind"] == "workload" && document["name"] == "mongo" } }
  let(:mongo_container) { mongo_workload.dig("spec", "containers").first }

  it "keeps the official Mongo entrypoint and binds to the GVC network" do
    expect(mongo_container).not_to have_key("command")
    expect(mongo_container["args"]).to include("--bind_ip_all")
  end
end
