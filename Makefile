# CI + dev helpers for smitchoksi.com
#
# Dev contexts:
#   INSIDE devcontainer  -> hugo is on PATH: use `make serve` / `make build`
#   OUTSIDE (host/macOS) -> no hugo: use `make docker-serve` / `make docker-build`
#     (throwaway hugomods container; Docker Desktop must be running)
#
# CI contexts:
#   LOCAL CI  (local-ci-*)  -> runs the workflow on your machine via act.
#     Free, uses your gh CLI auth, needs Docker. This is the default way
#     to publish. NOTE: `make local-ci-run` publishes FOR REAL — it pushes
#     to both the public site repo and this repo. Rehearse with
#     `make local-ci-dry`.
#   GITHUB CI (gh-ci-*)     -> the same workflow hosted on GitHub Actions.
#     Costs credits, so it stays disabled; toggle with gh-ci-enable /
#     gh-ci-disable (native GitHub workflow state — act ignores it, local
#     runs always work). Hosted runs need a PUBLISH_TOKEN repo secret
#     (PAT with write access to smit-io/docs + smit-io/smit-io.github.io):
#     gh secret set PUBLISH_TOKEN

WORKFLOW := publish.yml
HUGO_IMG := hugomods/hugo:exts
SITE_DIR := smitchoksi.com

.DEFAULT_GOAL := help

.PHONY: help submodules serve build docker-serve docker-build \
        local-ci-run local-ci-dry \
        gh-ci-enable gh-ci-disable gh-ci-status gh-ci-run

help: ## Show this help
	@echo "Inside devcontainer (hugo on PATH):"
	@grep -E '^(serve|build):.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Outside devcontainer (host, needs Docker):"
	@grep -E '^(docker-serve|docker-build):.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Local CI — act on this machine, free (host, needs act + gh + Docker):"
	@grep -E '^local-ci-[a-z]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "GitHub CI — hosted on Actions, costs credits (needs gh):"
	@grep -E '^gh-ci-[a-z]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Misc:"
	@grep -E '^submodules:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

submodules: ## Init/update theme + public submodules
	git submodule update --init --recursive

# ---------- Inside devcontainer (hugo on PATH) ----------

serve: submodules ## Hugo dev server at http://localhost:1313 (devcontainer)
	@command -v hugo >/dev/null || { echo "hugo not found — you are outside the devcontainer. Use 'make docker-serve' instead."; exit 1; }
	cd $(SITE_DIR) && hugo server

build: submodules ## Build site into smitchoksi.com/public (devcontainer)
	@command -v hugo >/dev/null || { echo "hugo not found — you are outside the devcontainer. Use 'make docker-build' instead."; exit 1; }
	cd $(SITE_DIR) && hugo --minify

# ---------- Outside devcontainer (host, throwaway Docker container) ----------

docker-serve: submodules ## Hugo dev server via Docker at http://localhost:1313 (host)
	@command -v docker >/dev/null && docker info >/dev/null 2>&1 || { echo "Docker not running. Inside the devcontainer? Use 'make serve' instead."; exit 1; }
	docker run --rm -it -p 1313:1313 -v $(PWD)/$(SITE_DIR):/src $(HUGO_IMG) hugo server --bind 0.0.0.0

docker-build: submodules ## Build site via Docker into smitchoksi.com/public (host)
	@command -v docker >/dev/null && docker info >/dev/null 2>&1 || { echo "Docker not running. Inside the devcontainer? Use 'make build' instead."; exit 1; }
	docker run --rm -v $(PWD)/$(SITE_DIR):/src $(HUGO_IMG) hugo --minify

# ---------- Local CI: act on this machine (free, default publish path) ----------

local-ci-run: submodules ## Run the publish workflow locally via act (PUSHES for real)
	@gh auth token >/dev/null 2>&1 || { echo "gh not authenticated. Run 'gh auth login' first."; exit 1; }
	@command -v docker >/dev/null && docker info >/dev/null 2>&1 || { echo "Docker not running — act needs it. Start Docker Desktop first."; exit 1; }
	act push -W .github/workflows/$(WORKFLOW) -s PUBLISH_TOKEN="$$(gh auth token)"

local-ci-dry: submodules ## Dry-run: list workflow steps without executing
	@command -v docker >/dev/null && docker info >/dev/null 2>&1 || { echo "Docker not running — act needs it. Start Docker Desktop first."; exit 1; }
	act push -n -W .github/workflows/$(WORKFLOW)

# ---------- GitHub CI: hosted on Actions (costs credits, keep disabled) ----------

gh-ci-enable: ## Enable the GitHub-hosted workflow (starts costing credits on push)
	gh workflow enable $(WORKFLOW)

gh-ci-disable: ## Disable the GitHub-hosted workflow (local CI still works)
	gh workflow disable $(WORKFLOW)

gh-ci-status: ## Show workflow state + recent hosted runs
	gh workflow list --all
	@echo
	gh run list --workflow=$(WORKFLOW) --limit 5 || true

gh-ci-run: ## Trigger a GitHub-hosted run (workflow must be enabled; needs PUBLISH_TOKEN secret)
	gh workflow run $(WORKFLOW)
