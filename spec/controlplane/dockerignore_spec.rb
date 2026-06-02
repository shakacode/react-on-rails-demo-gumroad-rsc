# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Control Plane Docker context" do
  let(:dockerignore_patterns) { Rails.root.join(".dockerignore").read.lines.map(&:strip) }

  it "excludes private key material from deployment images" do
    expect(dockerignore_patterns).to include("*.key", "*.pem", "*.p12", "*.pfx")
    expect(dockerignore_patterns).to include("config/master.key")
    expect(dockerignore_patterns).to include("config/credentials/*.key")
    expect(dockerignore_patterns).to include("config/credentials/**/*.key")
  end
end
