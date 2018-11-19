# Enabling emails on push

By enabling this service, you will be able to receive email notifications for
every change that is pushed to your project.

Navigate to the [Integrations page](project_services.md#accessing-the-project-services)
and select the **Emails on push** service to configure it.

In the _Recipients_ area, provide a list of emails separated by spaces or newlines.

You can configure any of the following settings depending on your preference.

- **Push events** - Email will be triggered when a push event is received.
- **Tag push events** - Email will be triggered when a tag is created and pushed.
- **Send from committer** - Send notifications from the committer's email address if the domain is part of the domain GitLab is running on (e.g. `user@gitlab.com`).
- **Disable code diffs** - Don't include possibly sensitive code diffs in notification body.

---

![Email on push service settings](img/emails_on_push_service.png)
