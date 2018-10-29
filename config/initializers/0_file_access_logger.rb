# FileUtils = Gitlab::Audit::MethodLogger.new('FileUtils', FileUtils, Gitlab::FileAccessJsonLogger)
# #IO = Gitlab::Audit::MethodLogger.new('IO', IO, Gitlab::FileAccessJsonLogger)
# File = Gitlab::Audit::MethodLogger.new('File', File, Gitlab::FileAccessJsonLogger)

# Gitlab::Audit::LogMethodCalls.stub(
#   FileUtils,
#   Gitlab::FileAccessJsonLogger
# )

Gitlab::Audit::MethodLogger.stub!(FileUtils, Gitlab::FileAccessJsonLogger,
  base_object: Module)

# Gitlab::Audit::MethodLogger.stub!(IO, Gitlab::FileAccessJsonLogger,
#   except_singleton_methods: [],
#   instance_methods: nil)
  
# Gitlab::Audit::MethodLogger.stub!(File, Gitlab::FileAccessJsonLogger,
#   except_singleton_methods: %i[new expand_path basename join dirname extname exist? file? readable? writable? realpath directory? mtime stat absolute_path],
#   instance_methods: [])

