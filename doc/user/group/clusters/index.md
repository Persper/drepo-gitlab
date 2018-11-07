# Group-level clusters

> [Introduced](https://gitlab.com/gitlab-org/gitlab-ce/issues/34758) in GitLab 10.5.

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

After a Kubernetes cluster is created or added on a project, an RBAC
authorization is automatically enforced by generating a restricted
service account to the project's namespace on the Cluster side.

Unlike project clusters, group clusters currently uses the super-user
role
([`cluster-admin`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles))
to perform its operations. It is planned in a [future
release](https://gitlab.com/gitlab-org/gitlab-ce/issues/53592) to
similarly use a restrcited service account for group clusters.

NOTE: **Note:**
RBAC support was introduced on
[11.4](https://gitlab.com/gitlab-org/gitlab-ce/issues/29398), and
Project namespace restriction was introduced on
[11.5](https://gitlab.com/gitlab-org/gitlab-ce/issues/51716)

## Environment scopes

When a project's group has Kubernetes clusters configured, the [project
environment evaluation] for environment scope will still take place
first but firstly at the project level, followed by the closest ancestor
group and followed by that group's parent and so on.

Extending the setup from the previous section, let's say we have the
following Kubernetes clusters:

| Cluster    | Environment scope   | Where     |
| ---------- | ------------------- | ----------|
| Development| `*`                 | Project 1 |
| Staging    | `staging/*`         | Project 1 |
| Production | `production/*`      | Project 1 |
| Group      | `test`              | Group 1   |

Given the above, the "test" job will still use the project's development
cluster, as it matches `*` on the project level.

If the Development cluster was deleted :

| Cluster    | Environment scope   | Where     |
| ---------- | ------------------- | ----------|
| Staging    | `staging/*`         | Project 1 |
| Production | `production/*`      | Project 1 |
| Group      | `test`              | Group 1   |

Then, the "test" job will fail to match any cluster on the project
level. Evaluation now moves up to the group, where it matches the Group
cluster. The Group cluster will be used for the "test" job.

[Helm Tiller]: https://docs.helm.sh/
[Ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[project environment evaluation]: ../../project/clusters/index.md#setting-the-environment-scope
[project Kubernetes clusters]: ../../project/clusters/index.md
[Auto DevOps]: ../../../topics/autodevops/index.md
