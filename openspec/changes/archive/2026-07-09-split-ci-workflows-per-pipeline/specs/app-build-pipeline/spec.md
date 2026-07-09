## REMOVED Requirements

### Requirement: App build only triggers for `app/**` changes
**Reason**: The `app/` directory is renamed to `universal/`, and the shared `dorny/paths-filter` job this requirement depended on is removed in favor of each workflow file's own native `paths` trigger.
**Migration**: See `universal-ci-pipeline`'s "Universal build only triggers for `universal/**` changes".

### Requirement: App build publishes a SHA-256 checksum alongside the APK
**Reason**: Superseded by the equivalent requirement under the renamed `universal-ci-pipeline` capability; behavior is unchanged, only the capability name moves.
**Migration**: See `universal-ci-pipeline`'s "Universal build publishes a SHA-256 checksum alongside the APK".

### Requirement: App build embeds a Build Tag for update checking
**Reason**: Superseded by the equivalent requirement under the renamed `universal-ci-pipeline` capability; behavior is unchanged, only the capability name moves.
**Migration**: See `universal-ci-pipeline`'s "Universal build embeds a Build Tag for update checking".

### Requirement: App build validation runs on pull requests and is a required status check
**Reason**: Superseded by the equivalent requirement under the renamed `universal-ci-pipeline` capability. The `lint-deploy` cross-reference is also dropped: `push-hello`/`release-universal`-style coupling to an unrelated `deploy/` lint job was never load-bearing and is removed for all pipelines by this change.
**Migration**: See `universal-ci-pipeline`'s "Universal build validation runs on pull requests and is a required status check".
