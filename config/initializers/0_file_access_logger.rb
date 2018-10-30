Gitlab::Audit::MethodLogger.stub!(
  FileUtils,
  Gitlab::FileAccessJsonLogger,
  unique_key: 'file_access_logger',
  base_object: Module)

Gitlab::Audit::MethodLogger.stub!(File, Gitlab::FileAccessJsonLogger,
  unique_key: 'file_access_logger',
  base_object: Object,
  singleton_methods: %i[new open chmod chown delete lchmod lchown link readlink rename size truncate unlink utime],
  instance_methods: %i[])

Gitlab::Audit::MethodLogger.stub!(IO, Gitlab::FileAccessJsonLogger,
  unique_key: 'file_access_logger',
  base_object: Object,
  singleton_methods: %i[open binread binwrite copy_stream for_fd foreach popen read readlines sysopen write],
  instance_methods: %i[])
