export const namespaceSelectOptions = state => {
  const serializedNamespaces = state.namespaces.map(({ path }) => ({ id: path, text: path }));

  return [
    { text: 'Groups', children: serializedNamespaces },
    {
      text: 'Users',
      children: [{ id: state.currentUserNamespace, text: state.currentUserNamespace }],
    },
  ];
};

export const isImportingAnyRepo = state => state.reposBeingImported.length > 0;

export const hasProviderRepos = state => state.providerRepos.length > 0;

export const hasImportedProjects = state => state.importedProjects.length > 0;
