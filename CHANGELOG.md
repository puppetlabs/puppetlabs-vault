<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v1.0.0](https://github.com/puppetlabs/puppetlabs-vault/tree/v1.0.0) - 2026-09-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-vault/compare/0.4.1...v1.0.0)

### Changed

- (BOLT-193): vault pdk update to puppet 9 [#21](https://github.com/puppetlabs/puppetlabs-vault/pull/21) ([gavindidrichsen](https://github.com/gavindidrichsen))

## [v0.4.1]()

### New features

* **Bump ruby_task_helper upper bound to < 2.0.0** ([#19](https://github.com/puppetlabs/puppetlabs-vault/pull/19))

## Release 0.4.0

### New features

* **Bump maximum Puppet version to include 7.x** ([#16](https://github.com/puppetlabs/puppetlabs-vault/pull/16))

## Release 0.3.2

### Bug fixes

* **Add PDK as a gem dependency**

  PDK is now a gem dependency for the module release pipeline

## Release 0.3.1

### Bug fixes

* **Add missing dependency to module metadata**
  ([#12](https://github.com/puppetlabs/puppetlabs-vault/pull/12))

  The module metadata now includes `ruby_task_helper` as a dependency.

## Release 0.3.0

### New features

* **Set `resolve_reference` task to private**
  ([#10](https://github.com/puppetlabs/puppetlabs-vault/pull/10))

  The `resolve_reference` task has been set to `private` so it no longer appears
  in UI lists.

## Release 0.2.2

### Bug fixes

* **Make auth parameter optional**
  ([#8](https://github.com/puppetlabs/puppetlabs-vault/pull/8))

  Previously the `auth` parameter was a required key to use the Vault plugin.
  It's now optional, enabling workflows such as connecting to a Vault agent
  which has it's own authentication with the server.

## Release 0.1.0

This is the initial release.
