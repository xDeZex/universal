## 1. Replace Workflow File

- [x] 1.1 Create `.github/workflows/ci.yml` with a `test` job that runs on `pull_request` and `push` to `main`, executing `flutter pub get`, `flutter test --concurrency=4 --reporter=compact`, and `flutter analyze`
- [x] 1.2 Add a `build-and-release` job to `ci.yml` with `needs: test` and `if: github.event_name == 'push'`, containing all build, artifact upload, and release steps from the existing `build-apk.yml`
- [x] 1.3 Delete `.github/workflows/build-apk.yml`

## 2. Verify and Merge

- [ ] 2.1 Open a PR with the workflow changes and confirm the `test` job runs and passes (and `build-and-release` is skipped)
- [ ] 2.2 Merge the PR

## 3. Configure Branch Protection

- [ ] 3.1 In GitHub Settings → Branches, add a branch protection rule for `main` requiring the `test` status check to pass before merging
- [ ] 3.2 Verify a subsequent test PR is blocked when the `test` job fails
