Apartment.configure do |config|
  config.use_schemas = true
  config.excluded_models = []
  config.default_schema = "public"
  config.persistent_schemas = ['shared_extensions']
  config.tenant_names = %w(drepo_project_pending drepo_project_completed)
  config.databaseless_tasks = ['gettext:compile']
end
