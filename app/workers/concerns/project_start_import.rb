# frozen_string_literal: true

# Used in EE by mirroring
module ProjectStartImport
  def start(project)
    if project.import_started? && project.import_state.jid == self.jid
      return true
    end

    project.import_state.start
  end
end
