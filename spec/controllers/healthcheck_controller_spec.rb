# frozen_string_literal: true

require "spec_helper"

describe HealthcheckController do
  def with_env(overrides)
    original = overrides.keys.index_with { ENV[_1] }
    overrides.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    original.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  describe "GET 'index'" do
    it "returns 'healthcheck' as text" do
      get :index

      expect(response.status).to eq(200)
      expect(response.body).to eq("healthcheck")
    end
  end

  describe "GET 'active_record_pool'" do
    it "is unavailable without the diagnostics token env var" do
      with_env("DEMO_DIAGNOSTICS_TOKEN" => nil) do
        request.headers["X-Demo-Diagnostics-Token"] = "token"

        get :active_record_pool

        expect(response).to have_http_status(:not_found)
      end
    end

    it "is unavailable when the diagnostics token does not match" do
      with_env("DEMO_DIAGNOSTICS_TOKEN" => "expected-token") do
        request.headers["X-Demo-Diagnostics-Token"] = "wrong-token"

        get :active_record_pool

        expect(response).to have_http_status(:not_found)
      end
    end

    it "returns sanitized process and Active Record pool diagnostics for an authorized request" do
      with_env(
        "DB_POOL_SIZE" => "10",
        "DEMO_DIAGNOSTICS_TOKEN" => "expected-token",
        "PUMA_WORKER_PROCESSES" => "1",
        "RAILS_MAX_THREADS" => "4",
        "WEB_CONCURRENCY" => "0",
      ) do
        request.headers["X-Demo-Diagnostics-Token"] = "expected-token"

        get :active_record_pool

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          "active_record",
          "env" => {
            "db_pool_size" => "10",
            "puma_worker_processes" => "1",
            "rails_max_threads" => "4",
            "web_concurrency" => "0",
          },
          "process" => a_hash_including("pid" => a_kind_of(Integer), "threads" => a_kind_of(Hash)),
        )
        expect(response.parsed_body["active_record"]).to include("size", "connections", "busy", "dead", "idle", "waiting", "checkout_timeout")
      end
    end
  end

  SIDEKIQ_QUEUE_NAMES = [:critical, :default].freeze

  shared_examples "sidekiq healthcheck" do |queue_type, queue_name, limit|
    context "#{queue_type} queues" do
      before do
        if queue_name.nil?
          allow(queue_class).to receive(:new).and_return(queue_double)
        else
          allow(queue_class).to receive(:new).with(queue_name).and_return(queue_double)
          (SIDEKIQ_QUEUE_NAMES - [queue_name]).each do |other_name|
            other_double = double("queue #{other_name} double", size: 0)
            allow(queue_class).to receive(:new).with(other_name).and_return(other_double)
          end
        end
      end

      let(:queue_double) { double("#{queue_type} double") }

      it "returns HTTP success when the jobs count is under limit" do
        allow(queue_double).to receive(:size).and_return(limit - 1)

        get :sidekiq

        expect(response.status).to eq(200)
        expect(response.body).to eq("Sidekiq: ok")
      end

      it "returns HTTP service_unavailable when the jobs count is over the limit" do
        allow(queue_double).to receive(:size).and_return(limit + 1)

        get :sidekiq

        expect(response.status).to eq(503)
        expect(response.body).to eq("Sidekiq: service_unavailable")
      end
    end
  end

  describe "GET 'sidekiq'" do
    describe "Sidekiq queues" do
      it_behaves_like "sidekiq healthcheck", :queue, :critical, 12_000 do
        let(:queue_class) { Sidekiq::Queue }
      end

      it_behaves_like "sidekiq healthcheck", :queue, :default, 300_000 do
        let(:queue_class) { Sidekiq::Queue }
      end
    end

    describe "Sidekiq retry set" do
      it_behaves_like "sidekiq healthcheck", :retry_set, nil, 20_000 do
        let(:queue_class) { Sidekiq::RetrySet }
      end
    end
  end

  describe "GET 'paypal_balance'" do
    context "when PayPal topup is not needed (Redis key is false)" do
      before do
        $redis.set(RedisKey.paypal_topup_needed, "false")
      end

      it "returns HTTP success" do
        get :paypal_balance

        expect(response.status).to eq(200)
        expect(response.body).to eq("PayPal balance: topup not required")
      end
    end

    context "when Redis key is not set" do
      before do
        $redis.del(RedisKey.paypal_topup_needed)
      end

      it "returns HTTP service_unavailable" do
        get :paypal_balance

        expect(response.status).to eq(503)
        expect(response.body).to eq("PayPal balance: topup required")
      end
    end

    context "when PayPal topup is needed (Redis key is true)" do
      before do
        $redis.set(RedisKey.paypal_topup_needed, "true")
      end

      it "returns HTTP service_unavailable" do
        get :paypal_balance

        expect(response.status).to eq(503)
        expect(response.body).to eq("PayPal balance: topup required")
      end
    end
  end
end
