<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import CiIcon from '../../vue_shared/components/ci_icon.vue';
import Select2Select from '../../vue_shared/components/select2_select.vue';
import { __ } from '../../locale';
import LoadingButton from '../../vue_shared/components/loading_button.vue';
import eventHub from '../event_hub';
import STATUS_MAP, { STATUSES } from '../constants';

export default {
  name: 'ProviderRepoTableRow',

  components: {
    CiIcon,
    Select2Select,
    LoadingButton,
  },

  props: {
    repo: {
      type: Object,
      required: true,
    },
  },

  data() {
    const { icon } = STATUS_MAP[STATUSES.NONE];

    return {
      ciIconStatus: {
        icon: `status_${icon}`,
        group: icon,
      },
      targetNamespace: this.$store.state.currentUserNamespace,
      newName: this.repo.sanitizedName,
    };
  },

  computed: {
    ...mapState(['namespaces', 'reposBeingImported']),

    ...mapGetters(['namespaceSelectOptions']),

    importButtonText() {
      return this.ciCdOnly ? __('Connect') : __('Import');
    },

    select2Options() {
      return {
        data: this.namespaceSelectOptions,
        containerCssClass: 'import-namespace-select qa-project-namespace-select',
      };
    },
  },

  created() {
    eventHub.$on('importAll', () => this.importRepo());
  },

  methods: {
    ...mapActions(['fetchImport']),

    importRepo() {
      return this.fetchImport({
        newName: this.newName,
        targetNamespace: this.targetNamespace,
        repo: this.repo,
      });
    },

    isLoadingImport(repoId) {
      return this.reposBeingImported.includes(repoId);
    },
  },
};
</script>

<template>
  <tr class="qa-project-import-row">
    <td>
      <a
        :href="repo.providerLink"
        rel="noreferrer noopener"
        target="_blank"
      >
        {{ repo.fullName }}
      </a>
    </td>
    <td class="d-flex">
      <select2-select 
        v-model="targetNamespace" 
        :options="select2Options"
      />
      <span class="px-2 import-slash-divider d-flex justify-content-center align-items-center">/</span>
      <input 
        v-model="newName" 
        type="text" 
        class="form-control import-project-name-input qa-project-path-field"
      />
    </td>
    <td>
      <ci-icon :status="ciIconStatus" />
      <span class="text-muted">{{ __('Not started') }}</span>
    </td>
    <td>
      <loading-button
        class="qa-import-button"
        :loading="isLoadingImport(repo.id)"
        :label="importButtonText"
        type="button"
        @click="importRepo"
      />
    </td>
  </tr>
</template>
