# TODO

## Hosted GitHub CI — DONE (2026-09-08)

Enabled: push to `main` triggers a hosted publish run; `make local-ci-run`
still works anytime, independently.

Setup that was done (repeat only if the PAT expires or is revoked):

- [x] Fine-grained PAT (github.com → Settings → Developer settings → Fine-grained tokens):
  - Repository access: `smit-io/docs`, `smit-io/hextra`, `smit-io/smit-io.github.io`
  - Repository permissions: Contents **read/write**
- [x] `gh secret set PUBLISH_TOKEN --repo smit-io/docs`
- [x] `make gh-ci-enable`

Notes:
- Actions are free on public repos — no credit concern while `smit-io/docs` stays public.
- Full write-up lives on the site: /docs/site-publishing (source:
  `smitchoksi.com/content/docs/site-publishing/_index.md`).
- Toggle anytime: `make gh-ci-disable` / `make gh-ci-enable`; check `make gh-ci-status`.

## Later

- [ ] Fix remaining Hugo deprecations in the theme fork (`languageCode` → `locale`,
      `.Site.Data`, `.Language.LanguageDirection` warnings on hugo ≥0.158).
- [ ] Decide on enabling the page context menu (`params.page.contextMenu.enable`
      in `smitchoksi.com/hugo.yaml`, currently false).
