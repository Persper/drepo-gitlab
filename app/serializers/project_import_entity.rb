# frozen_string_literal: true

class ProjectImportEntity < ProjectEntity
  include ImportHelper

  expose :import_source
  expose :import_status
  expose :human_import_status_name

  expose :provider_link do |project, options|
    provider_project_link_url(options[:provider], project[:import_source], options[:host_url])
  end
end
