# Documentation

## User documentation

- [API](api/README.md) Automate GitSwarm via a simple and powerful API.
- [GitSwarm as OAuth2 authentication service
  provider](integration/oauth_provider.md). It allows you to login to other
  applications from GitSwarm.
- [GitSwarm Basics](gitlab-basics/README.md) Find step-by-step how to start
  working on your commandline and on GitSwarm.
- [Importing into GitSwarm](workflow/importing/README.md) Prime a GitSwarm
  project from BitBucket, Git Fusion, GitHub, GitLab.com, or Subversion.
- [Markdown](markdown/markdown.md) GitSwarm's advanced formatting system.
- [Migrating from SVN](workflow/importing/migrating_from_svn.md) Convert a
  SVN repository to Git and GitSwarm
- [Permissions](permissions/permissions.md) Learn what each role in a
  project (guest/reporter/developer/master/owner) can do.
- [Profile Settings](profile/README.md)
- [Project Services](project_services/project_services.md) Integrate a
  project with external services, such as CI and chat.
- [Public access](public_access/public_access.md) Learn how you can allow
  public and internal access to projects.
- [SSH](ssh/README.md) Setup your ssh keys and deploy keys for secure
  access to your projects.
- [Web hooks](web_hooks/web_hooks.md) Let GitSwarm notify you when new code
  has been pushed to your project.
- [Workflow](workflow/README.md) Using GitSwarm functionality and importing
  projects from GitHub and SVN.

## CI Documentation

- [Quick Start](ci/quick_start/README.md)
- [Enable or disable GitLab CI](ci/enable_or_disable_ci.md)
- [Configuring project (.gitlab-ci.yml)](ci/yaml/README.md)
- [Configuring runner](ci/runners/README.md)
- [Configuring deployment](ci/deployment/README.md)
- [Using Docker Images](ci/docker/using_docker_images.md)
- [Using Docker Build](ci/docker/using_docker_build.md)
- [Using Variables](ci/variables/README.md)
- [Using SSH keys](ci/ssh_keys/README.md)
- [User permissions](ci/permissions/README.md)
- [API](ci/api/README.md)
- [Triggering builds through the API](ci/triggers/README.md)
- [Build artifacts](ci/build_artifacts/README.md)

### CI Languages

- [Testing PHP](ci/languages/php.md)

### CI Services

- [Using MySQL](ci/services/mysql.md)
- [Using PostgreSQL](ci/services/postgres.md)
- [Using Redis](ci/services/redis.md)
- [Using Other
  Services](ci/docker/using_docker_images.md#how-to-use-other-images-as-services)


### CI Examples

- [Test and deploy Ruby applications to
  Heroku](ci/examples/test-and-deploy-ruby-application-to-heroku.md)
- [Test and deploy Python applications to
  Heroku](ci/examples/test-and-deploy-python-application-to-heroku.md)
- [Test Clojure applications](ci/examples/test-clojure-application.md)
- Help your favorite programming language and GitLab by sending a merge
  request with a guide for that language.

## Administrator documentation

- [Migration from GitLab](install/migration_from_gitlab.md) How to migrate
  your existing GitLab workflow and repositories to GitSwarm.
- [Custom git hooks](hooks/custom_hooks.md) Custom git hooks (on the
  filesystem) for when web hooks aren't enough.
- [Install](install/README.md) Requirements, directory structures and
  installation from source.
- [Restart GitSwarm](administration/restart_gitlab.md) Learn how to restart
  GitSwarm and its components.
- [Integration](integration/README.md) How to integrate with systems such
  as JIRA, Redmine, LDAP and Twitter.
- [Issue closing](customization/issue_closing.md) Customize how to close an
  issue from commit messages.
- [Libravatar](customization/libravatar.md) Use Libravatar for user avatars.
- [Operations](operations/README.md) Keeping GitSwarm up and running
- [Log system](logs/logs.md) Log system
- [Environment Variables](administration/environment_variables.md) to
  configure GitSwarm.
- [Raketasks](raketasks/README.md) Backups, maintenance, automatic web hook
  setup and the importing of projects.
- [Security](security/README.md) Learn what you can do to further secure
  your GitSwarm instance.
- [System hooks](system_hooks/system_hooks.md) Notifications when users,
  projects and keys are changed.
- [Update](update/README.md) Update guides to upgrade your installation.
- [Welcome message](customization/welcome_message.md) Add a custom welcome
  message to the sign-in page.
- [Reply by email](incoming_email/README.md) Allow users to comment on
  issues and merge requests by replying to notification emails.
- [Migrate GitLab CI to GitSwarm](migrate_ci_to_ce/README.md) Follow this
  guide to migrate your existing GitLab CI data to GitSwarm.
- [Git LFS configuration](workflow/lfs/lfs_administration.md)
- [Housekeeping](administration/housekeeping.md) Keep your Git repository
  tidy and fast.
- [GitSwarm Performance Monitoring](monitoring/performance/introduction.md)
  Configure GitSwarm and InfluxDB for measuring performance metrics.

## Contributor documentation

- [Documentation styleguide](development/doc_styleguide.md) Use this
  styleguide if you are contributing to documentation.
- [Development](development/contribution.md) Details on contributing back
  changes.