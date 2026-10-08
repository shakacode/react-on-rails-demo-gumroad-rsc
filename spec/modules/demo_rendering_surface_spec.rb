# frozen_string_literal: true

require "spec_helper"

RSpec.describe DemoRenderingSurface do
  Request = Data.define(:host)

  def with_env(overrides)
    original = overrides.keys.index_with { ENV[_1] }
    overrides.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    original.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  it "selects the surface explicitly configured for a deployed app" do
    with_env("GUMROAD_RENDERING_SURFACE" => "next", "BRANCH" => nil) do
      expect(described_class.current(request: Request.new("gumroad.reactonrails.com"))).to eq(:next)
    end
  end

  it "derives the surface from a Control Plane app name" do
    with_env("GUMROAD_RENDERING_SURFACE" => nil, "BRANCH" => "react-on-rails-demo-gumroad-next") do
      expect(described_class.current(request: Request.new("rails-example.cpln.app"))).to eq(:next)
    end
  end

  it "supports the three local subdomains without process-level configuration" do
    with_env("GUMROAD_RENDERING_SURFACE" => nil, "BRANCH" => nil) do
      expect(described_class.current(request: Request.new("legacy.gumroad.dev"))).to eq(:legacy)
      expect(described_class.current(request: Request.new("next.gumroad.dev"))).to eq(:next)
      expect(described_class.current(request: Request.new("landing.gumroad.dev"))).to eq(:landing)
    end
  end

  it "keeps the current landing surface as the default" do
    with_env("GUMROAD_RENDERING_SURFACE" => nil, "BRANCH" => nil) do
      expect(described_class.current(request: Request.new("gumroad.reactonrails.com"))).to eq(:landing)
    end
  end

  it "rejects a misspelled explicit surface instead of silently serving the wrong renderer" do
    with_env("GUMROAD_RENDERING_SURFACE" => "nxt", "BRANCH" => nil) do
      expect { described_class.current(request: Request.new("example.com")) }
        .to raise_error(ArgumentError, /legacy, next, landing/)
    end
  end
end
