# frozen_string_literal: true

if Rails.env.staging? && ENV["BRANCH_DEPLOYMENT"] == "true" && ENV["SKIP_BRANCH_APP_ES_INDEX_SETUP"] != "true"
  Rails.application.config.after_initialize do
    [Link, Balance, Purchase, Installment, ConfirmedFollowerEvent, ProductPageView].each do |model|
      model.index_name("branch-app-#{ENV['DATABASE_NAME']}__#{model.name.parameterize}")
      model.__elasticsearch__.create_index!
    end
  end
end
