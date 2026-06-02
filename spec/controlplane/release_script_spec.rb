# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "open3"
require "pathname"
require "tmpdir"

RSpec.describe "Control Plane release script" do
  ROOT = Pathname.new(__dir__).join("../..").expand_path
  RELEASE_SCRIPT = ROOT.join(".controlplane/release_script.sh")

  def run_release_script(env = {})
    Dir.mktmpdir do |tmpdir|
      tmp_path = Pathname.new(tmpdir)
      calls_path = tmp_path.join("rails-calls.log")
      bin_path = tmp_path.join("bin")

      FileUtils.mkdir_p(bin_path)
      bin_path.join("rails").write(<<~SH)
        #!/bin/sh
        echo "$*" >> "$RAILS_CALL_LOG"
      SH
      FileUtils.chmod("+x", bin_path.join("rails"))

      stdout, stderr, status = Open3.capture3(
        {
          "ALLOW_DEMO_SEED" => nil,
          "DATABASE_HOST" => "mysql",
          "DATABASE_PORT" => "3306",
          "BRANCH" => "test-app",
          "ENTERPRISE_RECAPTCHA_API_KEY" => nil,
          "RAILS_CALL_LOG" => calls_path.to_s,
          "RECAPTCHA_LOGIN_SITE_KEY" => nil,
          "SKIP_CONTROL_PLANE_SERVICE_WAIT" => "true",
        }.merge(env),
        RELEASE_SCRIPT.to_s,
        chdir: tmp_path.to_s
      )

      calls = calls_path.exist? ? calls_path.read.lines.map(&:chomp) : []
      [status, stdout, stderr, calls]
    end
  end

  it "runs migrations without seeding by default" do
    status, _stdout, stderr, calls = run_release_script

    expect(status).to be_success, stderr
    expect(calls).to eq(["db:prepare"])
  end

  it "seeds demo data when explicitly enabled" do
    status, _stdout, stderr, calls = run_release_script("ALLOW_DEMO_SEED" => "true")

    expect(status).to be_success, stderr
    expect(calls).to eq(["db:prepare", "db:seed"])
  end

  it "fails production releases when CAPTCHA env is missing" do
    status, _stdout, stderr, calls = run_release_script("BRANCH" => "react-on-rails-demo-gumroad-rsc-production")

    expect(status).not_to be_success
    expect(stderr).to include("RECAPTCHA_LOGIN_SITE_KEY must be configured")
    expect(calls).to be_empty
  end

  it "runs production releases when CAPTCHA env is configured" do
    status, _stdout, stderr, calls = run_release_script(
      "BRANCH" => "react-on-rails-demo-gumroad-rsc-production",
      "RECAPTCHA_LOGIN_SITE_KEY" => "login-site-key",
      "ENTERPRISE_RECAPTCHA_API_KEY" => "enterprise-api-key"
    )

    expect(status).to be_success, stderr
    expect(calls).to eq(["db:prepare"])
  end
end
