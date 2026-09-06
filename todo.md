# TODO

## Enable hosted GitHub CI (when credits available)

Local CI (`make local-ci-run`) needs none of this — it uses gh CLI auth.

- [ ] Create fine-grained PAT (github.com → Settings → Developer settings → Fine-grained tokens):
  - Contents **read/write** on `smit-io/docs`
  - Contents **read/write** on `smit-io/smit-io.github.io`
  - Contents **read** on `smit-io/hextra`
- [ ] Add it as repo secret: `gh secret set PUBLISH_TOKEN --repo smit-io/docs`
- [ ] Enable the workflow: `make gh-ci-enable`
- [ ] Test with a manual run: `make gh-ci-run`, watch with `gh run watch`
- [ ] Verify: new commit in `smit-io.github.io` + `publish: bump public submodule [skip ci]` commit in `docs`
- [ ] If keeping it off after the test: `make gh-ci-disable`

Notes:
- Push to `main` triggers a hosted run while enabled; `workflow_dispatch` always available.
- The workflow's parent-bump commit carries `[skip ci]` so it never re-triggers itself.
- Check state anytime: `make gh-ci-status`
