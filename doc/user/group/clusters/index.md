# Group-level clusters

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/issues/34758) in GitLab 11.6.

## Overview

Similar to [project Kubernetes clusters], Group-level kubernetes
clusters allow you to connect a Kubernetes cluster to your group,
enabling to use the same cluster across projects.

## Installing applications

Gitlab provides a one-click install for various applications will be added directly
to your cluster.

NOTE: **Note:**
The applications will be installed in a dedicated namespace called
`gitlab-managed-apps`. In case you have added an existing Kubernetes cluster
with Tiller already installed, you should be careful as GitLab cannot
detect it. By installing it via the applications will result into having it
twice, which can lead to confusion during deployments.

| Application   | GitLab version | Description | Helm Chart |
| -----------   | :------------: | ----------- | ---------- |
| [Helm Tiller] | 10.2+ | Helm is a package manager for Kubernetes and is required to install all the other applications. It is installed in its own pod inside the cluster which can run the `helm` CLI in a safe environment. | n/a |
| [Ingress]     | 10.2+ | Ingress can provide load balancing, SSL termination, and name-based virtual hosting. It acts as a web proxy for your applications and is useful if you want to use [Auto DevOps] or deploy your own web apps. | [stable/nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) |

## RBAC compatibility

When a project deploys into a group cluster, GitLab currently uses the
admin service account
([`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles)).
It is planned in a [future
release](https://gitlab.com/gitlab-org/gitlab-ce/issues/53592) to
similarly use a restricted service account for group clusters.

NOTE: **Note:**
RBAC support was introduced on
[11.4](https://gitlab.com/gitlab-org/gitlab-ce/issues/29398), and
Project namespace restriction was introduced on
[11.5](https://gitlab.com/gitlab-org/gitlab-ce/issues/51716)

## Cluster precedence

GitLab will use the project's cluster if it is available and not disabled first before
using any cluster belonging to the group containing the project.

In the case of sub-groups, GitLab will use the cluster of the closest ancestor group
to the project, provided the cluster is not disabled.

## Environment scopes

NOTE: **Note:**
This is only available for [GitLab Premium][ee] where you can add more than
one Kubernetes cluster.

When a project's group has Kubernetes clusters configured, the [project
environment evaluation] for environment scope will still take place
first but firstly at the project level, followed by the closest ancestor
group and followed by that group's parent and so on.

For example, let's say we have the following Kubernetes clusters:

| Cluster    | Environment scope   | Where     |
| ---------- | ------------------- | ----------|
| Project    | `*`                 | Project   |
| Staging    | `staging/*`         | Project   |
| Production | `production/*`      | Project   |
| Test       | `test`              | Group     |
| Development| `*`                 | Group     | 


And the following environments are set in [`.gitlab-ci.yml`](../../../ci/yaml/README.md):

```yaml
stages:
- test
- deploy

test:
  stage: test
  script: sh test

deploy to staging:
  stage: deploy
  script: make deploy
  environment:
    name: staging/$CI_COMMIT_REF_NAME
    url: https://staging.example.com/

deploy to production:
  stage: deploy
  script: make deploy
  environment:
    name: production/$CI_COMMIT_REF_NAME
    url: https://example.com/
```
The result will then be:

- The Project cluster will be used for the "test" job.
- The Staging cluster will be used for the "deploy to staging" job.
- The Production cluster will be used for the "deploy to production" job.

[Helm Tiller]: https://docs.helm.sh/
[Ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[project environment evaluation]: ../../project/clusters/index.md#setting-the-environment-scope
[project Kubernetes clusters]: ../../project/clusters/index.md
[Auto DevOps]: ../../../topics/autodevops/index.md
