# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Control Plane database templates" do
  let(:database_templates) do
    %w[mysql mongo].to_h do |template|
      documents = YAML.safe_load_stream(Rails.root.join(".controlplane/templates/#{template}.yml").read, aliases: true)
      [template, documents]
    end
  end

  it "do not create database secrets with public placeholder passwords" do
    database_templates.each_value do |documents|
      expect(documents).not_to include(a_hash_including("kind" => "secret"))
      expect(documents.to_s).not_to include("replace-with-real")
    end
  end

  it "disable final snapshots for seed-recreatable demo databases" do
    database_templates.each_value do |documents|
      volumeset = documents.find { |document| document["kind"] == "volumeset" }
      snapshots = volumeset.fetch("spec").fetch("snapshots")

      expect(snapshots.fetch("createFinalSnapshot")).to eq(false)
      expect(snapshots).not_to have_key("retentionDuration")
    end
  end
end
