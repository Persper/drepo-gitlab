Dir[Rails.root.join("drepo/spec/support/helpers/*.rb")].each { |f| require f }
Dir[Rails.root.join("drepo/spec/support/shared_contexts/*.rb")].each { |f| require f }
Dir[Rails.root.join("drepo/spec/support/shared_examples/*.rb")].each { |f| require f }
Dir[Rails.root.join("drepo/spec/support/**/*.rb")].each { |f| require f }
