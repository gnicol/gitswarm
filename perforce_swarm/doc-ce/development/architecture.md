# $GitSwarm$ Architecture Overview

## Software delivery

There are two editions of GitSwarm: 'GitSwarm', based upon
[GitLab's Community Edition](https://gitlab.com/gitlab-org/gitlab-ce/tree/master),
and 'GitSwarm Enterprise Edition (EE)', which is based upon
[GitLab's Enterprise Edition](https://gitlab.com/gitlab-org/gitlab-ee/tree/master).

Both editions of GitSwarm are available as packages or source install
(via git).

Both editions of GitSwarm require an add-on component called gitlab-shell.
It is included in the GitSwarm packages. For source installs, it is
obtained from the ['gitlab-shell`
repository](https://gitlab.com/perforce/gitlab-shell/tree/release). New
versions are usually tags, but staying on the `release` branch gives you
the latest stable version. New releases are generally around the same time
as $GitSwarm$ releases, with exception for informal security updates deemed
critical.

## Physical office analogy

You can imagine $GitSwarm$ as a physical office.

**The repositories** are the goods (git repositories) that $GitSwarm$
handles. They can be stored in a "warehouse". This can be either a hard
disk, or something more complex, such as a NFS filesystem.

**Nginx** (a web server) acts like the front-desk. Users come to Nginx and
request actions to be done by workers in the office.

**The database** is a series of metal file cabinets with information on:
 - The goods in the warehouse (metadata, issues, merge requests etc);
 - The users coming to the front desk (permissions)

**Redis** is a communication board with "cubby holes" that can contain
tasks for office workers.

**Sidekiq** is a worker that primarily handles sending out emails. It takes
tasks from the Redis communication board.

**A Unicorn worker** is a worker that handles quick/mundane tasks. They
work with the communication board (Redis). Their job description:
 - Check permissions by checking the user session stored in a Redis "cubby
   hole".
 - Make tasks for Sidekiq.
 - Fetch stuff from the warehouse or move things around in there.

**Gitlab-shell** is a third kind of worker that takes orders from a fax
machine (SSH) instead of the front desk (HTTP). Gitlab-shell communicates
with Sidekiq via the "communication board" (Redis), and asks quick
questions of the Unicorn workers either directly or via the front desk.

**$GitSwarm$ (the application)** is the collection of processes and business
practices that the office is run by.

## System Layout

When referring to `~git` in the pictures it means the home directory of the
git user which is typically `/var/opt/gitswarm` for package installs, and
`/home/git` for source installs.

$GitSwarm$ is primarily installed within the `/opt/gitswarm` directory as the
`root` user. Working data, including repositories, databases, nginx
configuration, etc. exist in `/var/opt/gitswarm`. For example, the bare
repositories are located in `/var/opt/gitswarm/git-data/repositories`.

$GitSwarm$ is a Ruby on Rails application, so the particulars of the inner
workings can be learned by studying how a Ruby on Rails application works.

To serve respositories over SSH there's an add-on application called
gitlab-shell, which is installed in `/home/git/gitlab-shell`.

### Components

![$GitSwarm$ Diagram Overview](gitswarm_diagram_overview.png)

A typical install of $GitSwarm$ is on GNU/Linux. It uses Nginx as a web front
end to proxypass the Unicorn web server. By default, communication between
Unicorn and the front end is via a Unix domain socket, but forwarding
requests via TCP is also supported. The web front end accesses
`/opt/gitswarm/embedded/services/gitlab-rails/public`, bypassing the
Unicorn server, to serve static pages, uploads (e.g. avatar images or
attachments), and precompiled assets. $GitSwarm$ serves web pages and a
[$GitSwarm$ API](../api/README.md) using the Unicorn web server. It uses
Sidekiq as a job queue which, in turn, uses Redis as a non-persistent
database backend for job information, meta data, and incoming jobs.

$GitSwarm$ uses PostgreSQL for persistent database information (e.g. users,
permissions, issues, other meta data).

When serving repositories over HTTP/HTTPS, $GitSwarm$ utilizes the $GitSwarm$
API to resolve authorization and access as well as serving git objects.

The add-on component gitlab-shell serves repositories over SSH. It manages
the SSH keys within `/var/opt/gitswarm/.ssh/authorized_keys` for package
installs, or `/home/git/.ssh/authorized_keys`, which should not be manually
edited. gitlab-shell accesses the bare repositories directly to serve git
objects and communicates with Redis to submit jobs to Sidekiq for
$GitSwarm$ to process. gitlab-shell queries the $GitSwarm$ API to determine
authorization and access.

### Installation Folder Summary

To summarize, here's the [$GitSwarm$ directory structure](../install/structure.md).

### Processes

    ps aux | grep '^git'

$GitSwarm$ has several components to operate. As a system user (i.e. any user
that is not the `git` user) it requires a persistent database (PostreSQL)
and Redis database. It also uses Nginx to proxypass Unicorn. As the `git`
user it starts Sidekiq and Unicorn (a simple Ruby HTTP server running on
port `8080` by default). Under the $GitSwarm$ user there are normally 4
processes: `unicorn_rails master` (1 process), `unicorn_rails worker` (2
processes), `sidekiq` (1 process).

### Repository access

Repositories can be accessed via HTTP or SSH. HTTP cloning/push/pull
utilizes the $GitSwarm$ API and SSH cloning is handled by gitlab-shell
(previously explained).

## Troubleshooting

See the README for more information.
