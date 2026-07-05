# opnsense-repo

Signed pkg repository for aendryn's OPNsense plugins, served from the
`gh-pages` branch via GitHub Pages:

```
https://aendryn.github.io/opnsense-repo/FreeBSD_14_amd64/latest/
```

## Branches

- **`main`** (this branch) — source: the `os-repo-aendryn` bootstrap package
  and the workflow that publishes it.
- **`gh-pages`** — published output: the signed catalog and every plugin
  `.pkg`. Do not edit by hand; workflows deploy here.

## Bootstrap package

`os-repo-aendryn` configures pkg on an OPNsense box to trust and use this
repository. Its source lives in `net/repo-bootstrap/`. It is built and
published by `.github/workflows/publish-bootstrap.yml`, which runs only when
the bootstrap source changes or on manual dispatch. Bump `BOOTSTRAP_VERSION`
in that workflow when you change the source, or clients won't upgrade.

## Plugins

Each plugin lives in its own repository and publishes itself here
independently (deploying to `gh-pages` with `keep_files: true`, carrying over
every other package untouched). Publishing one plugin never rebuilds another
plugin or the bootstrap.

## Signing key

Every repo that deploys here — this one and each plugin repo — must sign the
catalog with the **same** key, matching
`net/repo-bootstrap/src/usr/local/share/aendryn/pubkey.rsa`. Store it as the
`PKG_SIGNING_KEY` Actions secret in each repo.
