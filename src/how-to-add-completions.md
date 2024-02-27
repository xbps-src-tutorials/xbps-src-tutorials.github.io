# How to add completions?

Programs may provide shell completions for them. If that it the case, they
should be packaged so that the user of the package can enjoy automatic
completions.

`xbps-src` provides a helper for that called `vcompletion`. It is usually called
in `post_install()`. It supports three types of shell completions: `bash`,
`fish` and `zsh`.

The procedure of including completions differs depending on how the project
provides completions:

<!-- toc -->

## Build system automatically installs completions.
This is the simplest of scenarios. You literally have to do nothing to get
completions, they are installed automatically.

This is used in
[`xmirror`](https://github.com/void-linux/void-packages/blob/3ddc63b10ff4f7a574996a3a43952c39c732101f/srcpkgs/xmirror/template)
for example.

You can see that [its Makefile installs completion in the `install`
target.](https://github.com/void-linux/xmirror/blob/64d5abfadc38628ae20d42b1d6999d4ce5c1d181/Makefile#L24-L26)

## Plain completions are in the repo
This is also easy to handle. You'll just have to call `vcompletion
<filename relative to $wrksrc or $build_wrksrc> <bash|fish|zsh>` in
`post_install()` or somewhere else.

This is used in
[`Clight`](https://github.com/void-linux/void-packages/blob/3ddc63b10ff4f7a574996a3a43952c39c732101f/srcpkgs/Clight/template#L19-L21)
for example.

When packaging a program, you should check whether there are additional files in
the repo that the use might want like completions and documentation. You should
install them to the package destdir if appropriate.

These additional files can be documented in project's `README.md`, `BUILDING.md`
or somewhere else. Or they might not be documented at all.

## The build system generates completions
Sometimes the build system needs to generate completions.

This should be familiar to you if you've read my [xbps-src packaging
tutorial](xbps-src-packaging-tutorial.md), because it's used in
[`bat`](packaging-bat.md) itself.

A disadvantage of this approach is that the shell completion generation might
have extra dependencies or it might require tweaking (like setting
`BAT_ASSETS_GEN_DIR` in
[`bat`](packaging-bat.md#installing-supplementary-files)).

If the build system generates completions, it also usually installs them. But
this isn't the case in `bat` for example.

## Program itself generates completions
This is the least practical way of handling completions for package maintainers.

Some program's argument handling libraries provide a way to automatically
generate shell scripts (usually to stdout) if a special subcommand (like in
[`mdBook`](https://github.com/void-linux/void-packages/commit/4eed2fffbc05a27a10a615d6c831f88390e7ba62)
using `completions` subcommand) or environmental variable (like in
[`hatch`](https://github.com/void-linux/void-packages/blob/3ddc63b10ff4f7a574996a3a43952c39c732101f/srcpkgs/hatch/template#L32)
using `_HATCH_COMPLETE`)
is passed.

As you sure remember, you can't run programs compiled for target architecture on
host. If the program is compiled (`hatch` mentioned above isn't by the way, so
the following advice doesn't apply to it), you'll have to use `build_helper=qemu`.

This is described in [tips and tricks](tips_and_tricks.md#qemu).

This is used in
[`mdBook`](https://github.com/void-linux/void-packages/blob/3ddc63b10ff4f7a574996a3a43952c39c732101f/srcpkgs/mdBook/template#L18-L21)
for example.

This is a common boilerplate for such programs:
```bash
for completion in bash fish zsh; do
	vtargetrun $DESTDIR/usr/bin/mdbook completions $completion > mdbook.$completion
	vcompletion mdbook.$completion $completion
done
```

It generates the completion using `mdbook completions bash|fish|zsh` and
redirects it into a file. The file is then `vcompletion`ed.

If the command isn't compiled, the procedure is similar, but without
`vtargetrun`.

A similar boilerplate exists for programs which generate completions by setting
an environmental variable (this is taken from
[`hatch`](https://github.com/void-linux/void-packages/blob/3ddc63b10ff4f7a574996a3a43952c39c732101f/srcpkgs/hatch/template#L32)):

```bash
for shell in zsh bash fish; do
	PYTHONPATH="${DESTDIR}/${py3_sitelib}" PATH="${DESTDIR}/usr/bin:${PATH}" \
	  _HATCH_COMPLETE="${shell}_source" hatch > "hatch.${shell}"
	vcompletion "hatch.${shell}" "${shell}"
done
```

`PYTHONPATH` and `PATH` are `hatch` specific, only `_HATCH_COMPLETE` is important
for completions.
