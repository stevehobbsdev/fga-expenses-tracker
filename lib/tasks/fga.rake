# frozen_string_literal: true

desc 'Tasks relating to FGA management'

namespace :fga do
  task seed: :environment do
    include FgaClient
  end

  task clean: :environment do
    include FgaClient
    delete_store(Rails.configuration.openfga[:store_id])
  end
end
