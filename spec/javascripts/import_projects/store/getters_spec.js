import {
  namespaceSelectOptions,
  isImportingAnyRepo,
  hasProviderRepos,
  hasImportedProjects,
} from '~/import_projects/store/getters';
import state from '~/import_projects/store/state';

describe('import_projects store getters', () => {
  let localState;

  beforeEach(() => {
    localState = state();
  });

  describe('namespaceSelectOptions', () => {
    const namespaces = [{ path: 'namespace-0' }, { path: 'namespace-1' }];
    const currentUserNamespace = 'current-user';

    it('returns an options array with a "Users" and "Groups" optgroups', () => {
      localState.namespaces = namespaces;
      localState.currentUserNamespace = currentUserNamespace;

      const optionsArray = namespaceSelectOptions(localState);
      const groupsGroup = optionsArray[0];
      const usersGroup = optionsArray[1];

      expect(groupsGroup.text).toBe('Groups');
      expect(usersGroup.text).toBe('Users');

      groupsGroup.children.forEach((child, index) => {
        expect(child.id).toBe(namespaces[index].path);
        expect(child.text).toBe(namespaces[index].path);
      });

      expect(usersGroup.children.length).toBe(1);
      expect(usersGroup.children[0].id).toBe(currentUserNamespace);
      expect(usersGroup.children[0].text).toBe(currentUserNamespace);
    });
  });

  describe('isImportingAnyRepo', () => {
    it('returns true if there are any reposBeingImported', () => {
      localState.reposBeingImported = new Array(1);

      expect(isImportingAnyRepo(localState)).toBe(true);
    });

    it('returns false if there are no reposBeingImported', () => {
      localState.reposBeingImported = [];

      expect(isImportingAnyRepo(localState)).toBe(false);
    });
  });

  describe('hasProviderRepos', () => {
    it('returns true if there are any providerRepos', () => {
      localState.providerRepos = new Array(1);

      expect(hasProviderRepos(localState)).toBe(true);
    });

    it('returns false if there are no providerRepos', () => {
      localState.providerRepos = [];

      expect(hasProviderRepos(localState)).toBe(false);
    });
  });

  describe('hasImportedProjects', () => {
    it('returns true if there are any importedProjects', () => {
      localState.importedProjects = new Array(1);

      expect(hasImportedProjects(localState)).toBe(true);
    });

    it('returns false if there are no importedProjects', () => {
      localState.importedProjects = [];

      expect(hasImportedProjects(localState)).toBe(false);
    });
  });
});
