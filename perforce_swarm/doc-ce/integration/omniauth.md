# OmniAuth

GitSwarm leverages OmniAuth to allow users to sign in using Twitter,
GitHub, and other popular services.

Configuring OmniAuth does not prevent standard GitSwarm authentication or
LDAP (if configured) from continuing to work. Users can choose to sign in
using any of the configured mechanisms.

- [Initial OmniAuth Configuration](#initial-omniauth-configuration)
- [Supported Providers](#supported-providers)
- [Enable OmniAuth for an Existing
  User](#enable-omniauth-for-an-existing-user)
- [OmniAuth configuration
  sample](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master#omniauth-google-twitter-github-login)

## Initial OmniAuth Configuration

Before configuring individual OmniAuth providers, there are a few global
settings that are in common for all providers that we need to consider.

- Omniauth needs to be enabled, see details below for example.
- `allow_single_sign_on` defaults to `false`. If `false` users must be
  created manually or they cannot sign in via OmniAuth.
- `block_auto_created_users` defaults to `true`. If `true` auto created
  users are blocked by default and must be unblocked by an administrator
  before they are able to sign in.
- **Note:** If you set `allow_single_sign_on` to `true` and
  `block_auto_created_users` to `false` please be aware that any user on
  the Internet could successfully sign in to your GitSwarm without
  administrative approval.

If you want to change these settings:

1.  Open the configuration file:

    ```sh
sudo editor /etc/gitswarm/gitswarm.rb
    ```

1.  Edit these lines:

    ```
gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = false
gitlab_rails['omniauth_block_auto_created_users'] = true
    ```

Now we can choose one or more of the Supported Providers below to continue
configuration.

## Supported Providers

- [Azure](azure.md)
- [Bitbucket](bitbucket.md)
- [Crowd](crowd.md)
- [Facebook](facebook.md)
- [GitHub](github.md)
- [GitLab.com](gitlab.md)
- [Google](google.md)
- [SAML](saml.md)
- [Shibboleth](shibboleth.md)
- [Twitter](twitter.md)

## Enable OmniAuth for an Existing User

Existing users can enable OmniAuth for specific providers after the account
is created. For example, if the user originally signed in with LDAP an
OmniAuth provider such as Twitter can be enabled. Follow the steps below to
enable an OmniAuth provider for an existing user.

1. Sign in normally - whether standard sign in, LDAP, or another OmniAuth
   provider.
1. Go to profile settings (the silhouette icon in the top right corner).
1. Select the "Account" tab.
1. Under "Connected Accounts" select the desired OmniAuth provider, such as
   Twitter.
1. The user is redirected to the provider. Once the user has authorized
   GitSwarm, they are redirected back to GitSwarm.

The chosen OmniAuth provider is now active and can be used to sign in to
GitSwarm from then on.

## Using Custom Omniauth Providers

GitSwarm uses [Omniauth](http://www.omniauth.org/) for authentication and
already ships with a few providers preinstalled (e.g. LDAP, GitHub,
Twitter). But sometimes that is not enough and you need to integrate with
other authentication solutions. For these cases you can use the Omniauth
provider.

### Steps

These steps are fairly general and you must figure out the exact details
from the Omniauth provider's documentation.

1.  Stop GitSwarm:

    ```bash
sudo service gitswarm stop
    ```

1.  Add the gem to your
    [Gemfile](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/Gemfile):

    ```bash
gem "omniauth-your-auth-provider"
    ```

1.  Install the new Omniauth provider gem by running the following command:

    ```bash
sudo -u git -H bundle install --without development test mysql --path vendor/bundle --no-deployment
    ```

    > These are the same commands you used in the [Install Gems
      section](#install-gems) with `--path vendor/bundle --no-deployment`
      instead of `--deployment`.

1.  Start GitSwarm:

    ```bash
sudo service gitlab start
    ````

### Examples

If you have successfully set up a provider that is not shipped with
GitSwarm itself, please let us know.

You can help others by reporting successful configurations and probably
share a few insights or provide warnings for common errors or pitfalls by
sharing your experience [in the public
Wiki](https://github.com/gitlabhq/gitlab-public-wiki/wiki/Custom-omniauth-provider-configurations).

While we can't officially support every possible authentication mechanism
out there, we'd like to at least help those with specific needs.