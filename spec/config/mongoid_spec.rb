# frozen_string_literal: true

require "spec_helper"
require "erb"
require "yaml"

RSpec.describe "mongoid configuration" do
  def with_env(overrides)
    original = overrides.keys.index_with { ENV[_1] }
    overrides.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }

    yield
  ensure
    original.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  def rendered_config
    YAML.safe_load(ERB.new(Rails.root.join("config/mongoid.yml").read).result)
  end

  it "defaults staging and production auth source to the configured database name" do
    with_env(
      "MONGO_DATABASE_URL" => "mongo.example:27017",
      "MONGO_DATABASE_NAME" => "gumroad_log_demo",
      "MONGO_DATABASE_USERNAME" => "gumroad",
      "MONGO_DATABASE_PASSWORD" => "password",
      "MONGO_AUTH_SOURCE" => nil
    ) do
      expect(rendered_config.dig("staging", "clients", "default", "options", "auth_source")).to eq("gumroad_log_demo")
      expect(rendered_config.dig("production", "clients", "default", "options", "auth_source")).to eq("gumroad_log_demo")
    end
  end

  it "allows Control Plane to override staging and production auth source" do
    with_env(
      "MONGO_DATABASE_URL" => "mongo.example:27017",
      "MONGO_DATABASE_NAME" => "gumroad_log_demo",
      "MONGO_DATABASE_USERNAME" => "gumroad",
      "MONGO_DATABASE_PASSWORD" => "password",
      "MONGO_AUTH_SOURCE" => "admin"
    ) do
      expect(rendered_config.dig("staging", "clients", "default", "options", "auth_source")).to eq("admin")
      expect(rendered_config.dig("production", "clients", "default", "options", "auth_source")).to eq("admin")
    end
  end
end
