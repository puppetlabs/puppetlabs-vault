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
