# Troubleshooting
This page describes fixes for common problems and ways of debugging uncommon
ones.

<!-- toc -->

## Check these first
### Being up to date
Having a outdated clone of
[`void-packages`](https://github.com/void-linux/void-packages) is the most
common cause for problems in `xbps-src`.

**`xbps-src` doesn't use remote repositories to resolve dependencies.** It uses
the template files instead in the repository. An advantage of this approach is
that it makes `xbps-src` more independent from the remote repositories, but a
major disadvantage is that this approach makes `xbps-src` more independent from
the remote repositories.

Let's say you have an old
[`void-packages`](https://github.com/void-linux/void-packages) clone and you
want to build some template. Your template depends on `somelib`. `xbps-src`
looks into `srcpkgs/somelibs/template` and it figures out that the most recent
version is `somelib-1.0_1`. But the real most recent version is for example
`somelib-2.0_1`. `xbps-src` then tries to fetch `somelib-1.0_1` from the remote
repositories.

Remote repositories do keep outdated packages, but they are regularly deleted.

If `xbps-src` is unable to locate the package in the remote repositories, it
tries to build it itself. This is wasteful when the dependency is in the remote
repo.

If your [`void-packages`](https://github.com/void-linux/void-packages) is really
out of date, it will fail to find a lot of dependencies, so it will try to build
everything itself. This can be slow.

You can update the branch you are on with
```
git pull --rebase upstream master
```

You have to have the `upstream` remote properly set up. You can use
```
git remote add upstream git@github.com:void-linux/void-packages.git
```
If you've cloned the repo using SSH and
```
git remote add upstream https://github.com/void-linux/void-packages.git
```
if you've cloned it with HTTPS.

You only have to add `upstream` once.

### Having clean masterdir
If there are leftovers from previous builds in the masterdir, bad things can
happen.

`xbps-src` cleans the masterdir upon successful build. This means that only
failed builds leave dirty masterdir behind.

You can clean it with
```
./xbps-src clean
```

If you suspect that the masterdir isn't in good state (which is unlikely, but it
can happen), you can use
```
./xbps-src zap
```

to remove it. You will have to run
```
./xbps-src binary-bootstrap
```
to set it up again.

## Troubleshooting help
Here are some useful things to know when troubleshooting a failing build:

### Stages
You can use
```
./xbps-src <stage> <package>
```

To execute only a specific stage of a build and all the preceding ones. For
example
```
./xbps-src build j4-dmenu-desktop
```
will run the `setup`, `fetch`, `extract`, `patch`, `configure` and `build`
stages. It won't run `check`, `install` nor any later stages.

Note that the entire stage is executed. `post_build()` gets also executed with
the aforementioned command.

When executing specific stages, masterdir doesn't get cleaned up upon
completion. This means that you can examine the builddir and destdir and debug
problems with it.

Note that you should [clean the masterdir after you're done.](#having-clean-masterdir)

### Chroot
You might also need to actually chroot into masterdir. Don't chroot manually,
`xbps-src` has you covered:
```
./xbps-src chroot
```

### exit 1
`xbps-src` terminates when any unchecked command returns non-zero. This means
that if you want to stop the build at a very specific line, you can put
```sh
exit 1
```
before it.

You can again examine the builddir and destdir after that.

Note that you should [clean the masterdir after you're done.](#having-clean-masterdir)

### Environment
`xbps-src` heavily overrides the environment during build. You shouldn't
override it, you should let `xbps-src` handle it. You should also prefer using
[buitin
variables](https://github.com/void-linux/void-packages/blob/master/Manual.md#global_vars)
instead of examining environmental variables manually. The environment set by
`xbps-src` should be considered a _implementation detail_ which may be subject
to change, so the template shouldn't have it's logic depend on it too much.

But if you need to know the environment to for example reproduce the issue
locally outside of the masterdir, you can put
```
env
```
before the targetted command or in a standalone function like `pre_configure()`
or some other one. You can then observe the output of `./xbps-src pkg` to see
the environment.

### Build style scripts
Build style scripts are located at
[`common/build-style`](https://github.com/void-linux/void-packages/tree/master/common/build-style).

Examining them can help you reproduce the problem. You can modify these files to
test things out, but you should `git restore` them after you're done.

### Notifying upstream
If you believe that a problem with the build is a upstream issue, you should
report it to the upstream developers by for example making a GitHub Issue in
their repo.

You should always check that a issue describing the problem isn't already open
or closed to avoid making duplicate issues.

You should also check whether the problem hasn't been fixed in `master` already.
If that is the case, the next upstream release will likely resolve the issue.
You can add a patch to the template in the meantime (and make a comment in the
header that the next release will make the patch obsolete). You can also
politely ask upstream when is the next release planned. I've seen some projects
which have had their latest release years ago and which have fixed a lot of
issues in `master`. This is unfortunate for package maintainers who only use
versioned releases.

Upstream maintainers may or may not be willing to act on an issue and fix it.
If the issue is related to cross compilation or musl, upstream might not have
"explicit" support for it (they don't test for different architectures of
libcs). If that is the case, remember that cross compiling the project or using
musl might not be the primary and "intended" usage of the project and the
maintainers may choose to prioritize more standard environments like native
compiling with glibc.

Submitting a pull request that fixes the problem, if you know how, can also be
very helpful. Upstream is much more likely to act on it.

Communicating with upstream can be hard sometimes. The project can be long dead
& last touched years ago, it might be using exotic hosting (it might not be on
GitHub) which might not provide a direct way to make issues, upstream's primary
way of communication could be a mailing list, there might simply not be any way
to contact the maintainers and more.

## Failing checks
See [contributing](xbps-src-tutorial/contributing.md#solving-check-errors).

## Other problems
### Builds use only a single thread
`xbps-src` uses `nproc` to figure out how many cores should the build systems
use. It should be installed on every Void system.

You can set the number of jobs manually by putting `XBPS_MAKEJOBS` to
`etc/conf`.

It is documented [in `etc/defaults.conf`](https://github.com/void-linux/void-packages/blob/master/etc/defaults.conf#L65-L70):
```bash
# [OPTIONAL]
# Number of parallel jobs to execute when building packages that
# use make(1) or alike commands. Defaults to the result of nproc(1).
# If nproc(1) is not available, defaults to 1.
#
#XBPS_MAKEJOBS=4
```

## Error messages
### \<package\> is not a bootstrap package and cannot be built without it
Make sure your `masterdir` is set up. You can set up a masterdir with
```
./xbps-src binary-bootstrap
```

### ERROR clone (Operation not permitted)
[Your user must be in the `xbuilder` group for `xbps-uchroot` to
work.](https://github.com/void-linux/void-packages/blob/master/README.md#xbps-uchroot1)

### ERROR unshare (Operation not permitted)
If you are trying to use
[`void-packages`](https://github.com/void-linux/void-packages) in a Docker
container or something similar, don't.

[`void-packages`](https://github.com/void-linux/void-packages) itself use
chroots (that's what masterdir is for), so you don't have to worry about package
builds breaking your computer.

If you insist, you can try [`ethereal` chroot
method](https://github.com/void-linux/void-packages/tree/master?tab=readme-ov-file#ethereal).
It **destroys host system it runs on**.
