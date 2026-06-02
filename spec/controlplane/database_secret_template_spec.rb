# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Control Plane database templates" do
  it "do not create database secrets with public placeholder passwords" do
    %w[mysql mongo].each do |template|
      documents = YAML.safe_load_stream(Rails.root.join(".controlplane/templates/#{template}.yml").read, aliases: true)

      expect(documents).not_to include(a_hash_including("kind" => "secret"))
      expect(documents.to_s).not_to include("replace-with-real")
    end
  end
end
