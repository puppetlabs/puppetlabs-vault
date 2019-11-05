## Release 0.2.2

### Bug fixes

* **Make auth parameter optional** ([#8](https://github.com/puppetlabs/puppetlabs-vault/pulls/8))

Previously the `auth` parameter was a required key to use the Vault plugin. It's now optional,
enabling workflows such as connecting to a Vault agent which has it's own authentication with the
server.

## Release 0.1.0

This is the initial release.
