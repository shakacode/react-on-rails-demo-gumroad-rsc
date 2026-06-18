# frozen_string_literal: true

require "digest"

class HealthcheckController < ActionController::Base
  DEMO_DIAGNOSTICS_TOKEN_HEADER = "X-Demo-Diagnostics-Token"
  private_constant :DEMO_DIAGNOSTICS_TOKEN_HEADER

  def index
    render plain: "healthcheck"
  end

  def active_record_pool
    return head :not_found unless demo_diagnostics_authorized?

    render json: {
      process: {
        pid: Process.pid,
        threads: Thread.list.group_by { |thread| thread.status || "dead" }.transform_values(&:count),
      },
      env: {
        db_pool_size: ENV["DB_POOL_SIZE"],
        puma_worker_processes: ENV["PUMA_WORKER_PROCESSES"],
        rails_max_threads: ENV["RAILS_MAX_THREADS"],
        web_concurrency: ENV["WEB_CONCURRENCY"],
      },
      active_record: ActiveRecord::Base.connection_pool.stat,
    }.merge(detailed_active_record_diagnostics)
  end

  def sidekiq
    enqueued_jobs_above_limit = SIDEKIQ_QUEUE_LIMITS.any? do |queue, limit|
      Sidekiq::Queue.new(queue).size > limit
    end

    enqueued_jobs_above_limit ||= Sidekiq::RetrySet.new.size > SIDEKIQ_RETRIES_LIMIT

    status = enqueued_jobs_above_limit ? :service_unavailable : :ok

    render plain: "Sidekiq: #{status}", status:
  end

  def paypal_balance
    topup_not_needed = $redis.get(RedisKey.paypal_topup_needed) == "false"
    status = topup_not_needed ? :ok : :service_unavailable
    message = topup_not_needed ? "topup not required" : "topup required"

    render plain: "PayPal balance: #{message}", status:
  end

  SIDEKIQ_QUEUE_LIMITS = { critical: 12_000, default: 300_000 }
  SIDEKIQ_RETRIES_LIMIT = 20_000
  private_constant :SIDEKIQ_QUEUE_LIMITS, :SIDEKIQ_RETRIES_LIMIT

  private
    def demo_diagnostics_authorized?
      token = ENV["DEMO_DIAGNOSTICS_TOKEN"].presence
      return false if token.blank?

      provided_token = request.headers[DEMO_DIAGNOSTICS_TOKEN_HEADER].to_s
      ActiveSupport::SecurityUtils.secure_compare(
        Digest::SHA256.hexdigest(provided_token),
        Digest::SHA256.hexdigest(token)
      )
    end

    def detailed_active_record_diagnostics
      return {} unless params[:details] == "true"

      {
        active_record_connections: ActiveRecord::Base.connection_handler.connection_pool_list.flat_map do |pool|
          pool.connections.map.with_index do |connection, index|
            {
              pool: pool.db_config.name,
              index:,
              in_use: connection.in_use?,
              owner: thread_diagnostics(connection.owner),
            }
          end
        end,
        thread_backtraces: Thread.list.map { |thread| thread_diagnostics(thread, include_backtrace: true) },
      }
    end

    def thread_diagnostics(thread, include_backtrace: false)
      return if thread.nil?

      {
        class: thread.class.name,
        object_id: thread.object_id,
        alive: thread.respond_to?(:alive?) ? thread.alive? : nil,
        status: thread.respond_to?(:status) ? thread.status : nil,
      }.tap do |payload|
        payload[:backtrace] = Array(thread.backtrace).first(12) if include_backtrace && thread.respond_to?(:backtrace)
      end
    end
end
