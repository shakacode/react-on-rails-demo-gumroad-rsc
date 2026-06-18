# frozen_string_literal: true

module LiveActiveRecordConnectionCleanup
  extend ActiveSupport::Concern

  private
    def clear_live_active_record_connections
      yield
    ensure
      ActiveRecord::Base.connection_handler.clear_active_connections!(:all)
      ActiveRecord::Base.connection_handler.each_connection_pool(&:reap)
    end
end
