# Requirements

## Operating Systems

### Supported Unix distributions

- Ubuntu 12.04 or 14.04
- CentOS 6.6 or higher, or 7.0 or higher
- Red Hat Enterprise Linux (RHEL) 6.6 or higher, or 7.0 or higher

> Note: $GitSwarm$ is only available for 64-bit systems.

See the [installation instructions](README.md).

### Unsupported Unix distributions

- OS X
- Arch Linux
- Fedora
- Gentoo
- FreeBSD

### Non-Unix operating systems such as Windows

$GitSwarm$ is developed for Unix operating systems. $GitSwarm$ does **not** run
on Windows and we have no plans of supporting it in the near future.
Please consider using a virtual machine to run $GitSwarm$.

## Ruby versions

$GitSwarm$ requires Ruby (MRI) 2.1 You will have to use the standard MRI
implementation of Ruby. We love JRuby and Rubinius but $GitSwarm$ needs
several Gems that have native extensions.

## Hardware requirements

### Storage

The necessary hard drive space largely depends on the size of the repos you
want to store in $GitSwarm$ but as a *rule of thumb* you should have at least
twice as much free space as all your repos combined take up.

Note that if you are mirroring projects to Helix Server using the [locally
provisioned](auto_provision.md) Helix Git Fusion Server, you will want at
least four times as much free space as all your repos combined.

If you want to be flexible about growing your hard drive space in the
future consider mounting it using LVM so you can add more hard drives when
you need them.

Apart from a local hard drive you can also mount a volume that supports the
network file system (NFS) protocol. This volume might be located on a file
server, a network attached storage (NAS) device, a storage area network
(SAN) or on an Amazon Web Services (AWS) Elastic Block Store (EBS) volume.

If you have enough RAM memory and a recent CPU the speed of $GitSwarm$ is
mainly limited by hard drive seek times. Having a fast drive (7200 RPM and
up) or a solid state drive (SSD) will improve the responsiveness of
$GitSwarm$.

### CPU

For production use, it is recommended $GitSwarm$ be run on a dedicated server.
The Helix Server and Helix Git Fusion products should ideally be installed
on their own independent machines. In that configuration:

- 1 core supports up to 100 users, but performance may suffer as all
  workers and background jobs run on the same core
- **2 cores** is the **recommended minimum** number of cores and supports
  up to 500 users
- 4 cores supports up to 2,000 users
- 8 cores supports up to 5,000 users
- 16 cores supports up to 10,000 users
- 32 cores supports up to 20,000 users
- 64 cores supports up to 40,000 users

By default, $GitSwarm$ will attempt to automatically provision an instance
of Helix Server and Helix Git Fusion all on the local system. When running
all components on the same machine, we suggest a minimum of 4 cores.

### Memory

You need at least 2GB of addressable memory (RAM + swap) to install and use
$GitSwarm$! With less memory, $GitSwarm$ will give strange errors during the
reconfigure run and 500 errors during usage.

For production use, it is recommended $GitSwarm$ be run on a dedicated server.
The Helix Server and Helix Git Fusion products should ideally be installed
on their own independent machines. In that configuration:

- 2GB RAM is the absolute minimum, but we strongly **advise against** this
  amount of memory. See the Unicorn Workers section below for more advice.
- **4GB RAM** is the **recommended** memory size and supports up to 1,000
  users
- 8GB RAM supports up to 2,000 users
- 16GB RAM supports up to 4,000 users
- 32GB RAM supports up to 8,000 users
- 64GB RAM supports up to 16,000 users
- 128GB RAM supports up to 32,000 users

Notice: The 25 workers of Sidekiq will show up as separate processes in
your process overview (such as top or htop) but they share the same RAM
allocation since Sidekiq is a multithreaded application. See the section
below about Unicorn workers.

## Unicorn Workers

It is possible to increase the amount of unicorn workers and this will
usually help to reduce the response time of the applications and
increase the ability to handle parallel requests.

For most instances we recommend using: CPU cores + 1 = unicorn workers. So
for a machine with 2 cores, 3 unicorn workers is ideal.

A **minimum** of **3** unicorn workers is required for concurrent use of
the system.

For all machines that have 1GB and up we recommend a minimum of three
unicorn workers. If you have a 512MB machine with a magnetic (non-SSD) swap
drive we recommend to configure only one Unicorn worker to prevent
excessive swapping. With one Unicorn worker only git over ssh access will
work because the git over HTTP access requires two running workers (one
worker to receive the user request and one worker for the authorization
check). If you have a 512MB machine with a SSD drive you can use two
Unicorn workers, this will allow HTTP access although it will be slow due
to swapping.

If you need to adjust the Unicorn timeout or the number of workers you can
use the following settings in `/etc/gitswarm/gitswarm.rb`:

```ruby
unicorn['worker_processes'] = 3
unicorn['worker_timeout'] = 60
```

Run `sudo gitswarm-ctl reconfigure` for the change to take effect.

## Database

If you want to run the database separately, the **recommended** database
size is **1 MB per user**.

## Redis and Sidekiq

Redis stores all user sessions and the background task queue. The storage
requirements for Redis are minimal, about 25kB per user. Sidekiq processes
the background jobs with a multithreaded process. This process starts with
the entire Rails stack (200MB+) but it can grow over time due to memory
leaks. On a very active server (10,000 active users) the Sidekiq process
can use 1GB+ of memory.

## Supported web browsers

- Chrome (Latest stable version)
- Firefox (Latest released version and [latest ESR
  version](https://www.mozilla.org/en-US/firefox/organizations/))
- Safari 7+ (known problem: required fields in html5 do not work)
- Opera (Latest released version)
- Internet Explorer (IE) 10+, but please make sure that you have the
  `Compatibility View` mode disabled.
