<template>
  <div class="check-username-form">
    <form
      id="check-username"
      class="group-form gl-show-field-errors"
      action="/-/drepo/username_verified"
      accept-charset="UTF-8"
      method="post"
    >
      <input name="utf8" type="hidden" value="✓" />
      <input type="hidden" name="_method" value="patch" />
      <div class="form-group group-name-holder col-sm-12">
        <label class="label-bold" for="drepo_users_username">Pick a username</label>
        <input
          id="drepo_users_username"
          class="form-control input-lg"
          required="required"
          title="Please fill in an available username."
          autofocus="autofocus"
          type="text"
          name="username"
          placeholder="My Awesome Username"
        />
      </div>

      <div class="form-actions">
        <input
          type="submit"
          class="btn btn-success"
          value="Submit"
          :disabled="!isSubmittable"
        />
      </div>
    </form>
  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex';

export default {
  name: 'CheckUsername',

  data() {
    return {
      isUsernameAvailable: true,
    };
  },

  computed: {
    ...mapState(['web3Client', 'accountAddress', 'unlockOptionState', 'gasLimit']),

    ...mapGetters(['isUnlocked']),

    isSubmittable() {
      return this.isUsernameAvailable && this.isUnlocked;
    },
  },
};
</script>

<style scoped>
.check-username-form {
  margin-top: 60px;
}
</style>
