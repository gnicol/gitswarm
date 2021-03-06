# Migration from GitLab

## Introduction

If you already have a deployed GitLab instance with existing projects, but
wish to use $GitSwarm$, it is possible to migrate your $GitLab$ data (workflow
+ Git repositories) over to $GitSwarm$. This will allow you to have the
complete and supported offering from one vendor, as well as leveraging
Perforce Helix as the master for all assets.

## Requirements

1.  **Compatible versions**

    Only the following version combinations of $GitLab$ and $GitSwarm$ are
    supported for migration. This is a hard requirement; the migration
    process **will not work** unless your $GitLab$ and $GitSwarm$ instances
    match one of the version combinations below:

    |$GitLab$|$GitSwarm$|
    |---|---|
    |8.0.5|15.4|

    **Important Notes**:
    * $GitLab$ to $GitSwarm$ migration is not supported on $GitSwarm$ versions
      less than 15.4 ($GitLab$ 8.0.5).
    * Migration is supported across differing operating systems (e.g.
      migration from $GitLab$ running on CentOS/RHEL 6.6+ to $GitSwarm$ running
      on Ubuntu 14).

1.  **An existing $GitLab$ install**

    If the $GitLab$ instance you're looking to migrate from is not on the
    above list, you will need to follow [these
    instructions](https://about.gitlab.com/update/) to upgrade as necessary
    to a supported version (>= 8.0.5).

1.  **A new, up-to-date $GitSwarm$ install**

    If the $GitSwarm$ instance you're looking to migrate to is not on the
    above list, you will need to follow [these
    instructions](../update/README.md) to upgrade as necessary to a
    supported version.

    Migrating $GitLab$ to an existing $GitSwarm$ (one that has existing users,
    projects and repositories) will result in this data being overwritten
    and/or destroyed during the migration. It is highly recommended that
    you only migrate to a fresh/clean $GitSwarm$ instance to avoid this
    issue.

    If the $GitLab$ install from which you are migrating has attachments, you
    will either need to use the same hostname for your $GitSwarm$ install, or
    once migration is complete, you will need to change the $GitSwarm$
    instance's hostname to match the original $GitLab$ instance's hostname.

1.  **Recommended Approach**

    The recommended approach is to upgrade your $GitLab$ and $GitSwarm$
    instances to the most up-to-date combination ($GitLab$ 8.0.5 and $GitSwarm$
    15.4). Upgrading to $GitSwarm$ 15.4 (and $GitLab$ 8.0.5) is an absolute
    requirement for $GitSwarm$, since migration is not supported in earlier
    versions. See [these instructions](../update/README.md) for how to
    upgrade.

    It is also recommended that the same hostname be used for both the
    $GitLab$ and $GitSwarm$ instances, since this will ensure that attachments
    on merge requests and comments will still be downloadable
    post-migration.

## Migration Process

1.  **Perform a backup of your source $GitLab$ instance**

    Follow [these
    instructions](http://docs.gitlab.com/ce/raketasks/backup_restore.html)
    to perform a backup on the $GitLab$ instance from which you are
    migrating.

    After the backup process is complete, it will report the name of the
    backup file created:

    ```
    ...
    done
    Dumping uploads ...
    done
    Dumping builds ...
    done
    Creating backup archive: 1446498774_gitlab_backup.tar ... done
    Uploading backup archive to remote storage  ... skipped
    ...
    ```

    It is important to note the name of the backup file in the above
    output, as well as the timestamp (numeric) portion of the file. In the
    above case, the file is called `1446498774_gitlab_backup.tar` and the
    timestamp portion of the file is `1446498774`.

    Backup files are created under the `/var/opt/gitlab/backups/`
    directory.

1.  **Copy the backup archive to the destination $GitSwarm$ instance**

    The backup process above will result in the creation of a .tar file,
    which contains a backup of your workflow (users, projects, merge
    requests) as well as the corresponding Git repositories. You will need
    to copy the file created above to the $GitSwarm$ instance you are
    restoring to, and place the file under `/var/opt/gitswarm/backups/`.

    The backup file will be owned by the `git` user, so you will either
    need to perform the copy as `git`, or change the file permissions so
    the file can be read. For example, with the file above:

    ```bash
    chmod a+r /var/opt/gitlab/backups/1446498774_gitlab_backup.tar
    ```

1.  **Restore the backup archive against the destination $GitSwarm$
    instance**

    Before performing the restore, please review the [following
    note](#additional-help), since a workaround regarding attachments may
    apply to your migration.

    Follow [these
    instructions](../raketasks/backup_restore.md#omnibus-installations) for
    restoring the backup on your $GitSwarm$ instance, ensuring that you use
    the correct `TIMESTAMP` value that you made note of in step 1 of the
    migration process.

    This process will restore the database, upgrade it to the latest
    $GitSwarm$ schema, and then restore any backed-up repositories to your
    $GitSwarm$ instance. Once the backup process is complete and your
    $GitSwarm$ instance has been (re)started, you can then continue with
    enabling [Helix Mirroring for your existing
    projects](../workflow/helix_mirroring/overview.md), to gain the full
    benefit of using $GitSwarm$.

    As a final step, if you are using the same FQDN (fully-qualified domain
    name) for both your $GitLab$ and $GitSwarm$ instances, you should ensure
    that the server SSH keys are the same on both servers. The instructions
    for doing this [can be found
    here](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).
    This is necessary, since users who had previously connected to your
    $GitLab$ instance will already have a server fingerprint stored.

## Additional Help

1.  **Attachments can only be migrated if the hostname of the $GitSwarm$
    instance matches the originating $GitLab$ instance.**

     This is a known issue; the workaround is to ensure that the $GitSwarm$
     instance to which you are restoring has the same fully-qualified
     domain name (FQDN) as the $GitLab$ instance from which you took the
     backup. You will also need to update the `external_url` entry in
     `/etc/gitswarm/gitswarm.rb` before performing the restore.

1.  **After performing the restore, running the recommended check results
    in the following file permissions errors:**

    ```
    Repo base access is drwxrws---? ... no
      Try fixing it:
      sudo chmod -R ug+rwX,o-rwx /var/opt/gitswarm/git-data/repositories
      sudo chmod -R ug-s /var/opt/gitswarm/git-data/repositories
      find /var/opt/gitswarm/git-data/repositories -type d -print0 | sudo xargs -0 chmod g+s
      For more information see:
      doc/install/installation.md in section "GitLab Shell"
      Please fix the error above and rerun the checks.
    hooks directories in repos are links: ...
    ```

    ```
    Tmp directory writable? ... yes
    Uploads directory setup correctly? ... no
      Try fixing it:
      sudo chmod 0750 /var/opt/gitswarm/gitlab-rails/uploads
      For more information see:
      doc/install/installation.md in section "GitLab"
      Please fix the error above and rerun the checks.
    Init script exists? ... skipped (omnibus-gitlab has no init script)
    Init script up-to-date? ... skipped (omnibus-gitlab has no init script)
    projects have namespace: ...
    ```

    These problems can be corrected by running the following commands:

    ```bash
    sudo chmod -R ug+rwX,o-rwx /var/opt/gitswarm/git-data/repositories
    sudo chmod -R ug-s /var/opt/gitswarm/git-data/repositories
    find /var/opt/gitswarm/git-data/repositories -type d -print0 | sudo xargs -0 chmod g+s
    sudo chmod 0750 /var/opt/gitswarm/gitlab-rails/uploads
    ```

1.  **When performing a restore, the following database error may be
    seen:**

    ```
    psql:/var/opt/gitlab/backups/db/database.sql:22: ERROR:  must be owner of extension plpgsql
    psql:/var/opt/gitlab/backups/db/database.sql:2931: WARNING:  no privileges could be revoked for "public" (two occurences)
    psql:/var/opt/gitlab/backups/db/database.sql:2933: WARNING:  no privileges were granted for "public" (two occurences)
    ```

    Please see [this
    document](../raketasks/backup_restore.md#restoring-database-backup-using-omnibus-packages-outputs-warnings)
