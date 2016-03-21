# Updating GitSwarm EE to 2016.1

## Pre-update considerations

GitSwarm EE can only restore backups made on the same version. Hence, a
backup of GitSwarm EE 2015.4 can only be restored to an instance running
2015.4, and not on 2016.1 or higher versions. Although, upgrading GitSwarm
EE should not result in data corruption, we recommend taking backups of
your existing version before you run an upgrade.

If you are using CentOS or RHEL, and have upgraded the OS distribution on
your GitSwarm EE server from 6.x to 7.x, you need to update the URL in the
Perforce repository configuration. For example, if
`/etc/yum.repos.d/perforce.repo` contains:

```
baseurl=http://package.perforce.com/yum/rhel/6/x86_64
```

you must edit that line to read:

```
baseurl=http://package.perforce.com/yum/rhel/7/x86_64
```

After such an adjustment, we recommend that you run the following command
to remove any old dependencies:

```bash
sudo yum clean all
```

## Performing the update to 2016.1

1.  **Download the 2016.1 GitSwarm EE package and install it.**

    ```
    curl https://package.perforce.com/bootstrap/gitswarm-ee.sh | sudo sh -
    ```

    The script should add the Perforce package repository, and install the
    latest version of GitSwarm EE. The upgrade will create a backup of your
    existing GitSwarm EE data before fully installing.

1.  **Check the application status.**

    Check if GitSwarm EE and its environment are configured correctly:

    ```
    sudo gitswarm-rake gitswarm:check
    ```

# New configuration options

*  **Discovering new config options**

    GitSwarm EE doesn't update your `/etc/gitswarm/gitswarm.rb` for you,
    but we do include an updated example template:
    `/opt/gitswarm/etc/gitswarm.rb.template`. You can see what sort of
    config options have been changed since last release by running:

    ```
    sudo diff /etc/gitswarm/gitswarm.rb /opt/gitswarm/etc/gitswarm.rb.template
    ```