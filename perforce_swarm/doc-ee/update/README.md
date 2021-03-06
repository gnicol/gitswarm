# Updating $GitSwarm$ to 2016.2

## Pre-update considerations

$GitSwarm$ can only restore backups made on the same version. Hence, a
backup of $GitSwarm$ 2015.4 can only be restored to an instance running
2015.4, and not on 2016.2 or higher versions. Although, updating $GitSwarm$
should not result in data corruption, we recommend taking backups of your
existing version before you run an update.

If you are using CentOS or RHEL, and have updated the OS distribution on
your $GitSwarm$ server from 6.x to 7.x, you need to update the URL in the
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

## Update dependencies

If you have any repos mirroring their content into Helix Git Fusion, we
strongly recommend that you update Helix Git Fusion and the Helix
Versioning Engine prior to updating $GitSwarm$.

-   **For Ubuntu:**

    ```bash
    sudo apt-get install helix-git-fusion-base helix-p4d
    ```

-   **For CentOS/RHEL:**

    ```bash
    sudo yum install helix-git-fusion-base helix-p4d
    ```

> **Important:** Depending on the verion of the `helix-p4d` you may have
> installed previously, there may be schema/data migrations required
> (updating the `helix-p4d` package does not automatically restart the
> service). Schema/data migrations in the Helix Versioning Engine are
> typically performed by running `p4d -xu`. For more information, see the
> [Upgrading
> p4d](https://www.perforce.com/perforce/doc.current/manuals/p4sag/chapter.install.html#install.upgrade.2013.2_and_earlier)
> section in the [Helix Versioning Engine Administrator Guide:
> Fundamentals](https://www.perforce.com/perforce/doc.current/manuals/p4sag/index.html).

> **Important:** If you are upgrading from $GitSwarm$ 2015.3 or prior, and
> you had GitLab CI enabled, you must update to $GitSwarm$ 2015.4 before
> you update to $GitSwarm$ 2016.2.

## Performing the update to 2016.2

1.  **Download the 2016.2 $GitSwarm$ package and install it.**

    ```bash
    curl https://package.perforce.com/bootstrap/$GitSwarmPackage$.sh | sudo sh -
    ```

    The script should add the Perforce package repository, and install the
    latest version of $GitSwarm$. The update will create a backup of your
    existing $GitSwarm$ data before fully installing.

1.  **Check the application status.**

    Check if $GitSwarm$ and its environment are configured correctly:

    ```bash
    sudo gitswarm-rake gitswarm:check
    ```

    If you find that $GitSwarm$ does not seem to be operating correctly
    after the update, it could be that one or more $GitSwarm$ services did
    not restart correctly. Should this happen, run:

    ```bash
    sudo gitswarm-ctl restart
    ```

# New configuration options

*  **Discovering new config options**

    $GitSwarm$ doesn't update your `/etc/gitswarm/gitswarm.rb` for you, but
    we do include an updated example template:
    `/opt/gitswarm/etc/gitswarm.rb.template`. You can see what sort of
    config options have been changed since last release by running:

    ```bash
    sudo diff /etc/gitswarm/gitswarm.rb /opt/gitswarm/etc/gitswarm.rb.template
    ```
