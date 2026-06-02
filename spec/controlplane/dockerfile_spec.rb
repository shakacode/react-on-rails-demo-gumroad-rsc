# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Control Plane Dockerfile" do
  let(:dockerfile) { Rails.root.join(".controlplane/Dockerfile").read }

  it "does not accept private Bundler credentials as Docker build args" do
    expect(dockerfile).not_to include("BUNDLE_GEMS__CONTRIBSYS__COM")
  end
end
