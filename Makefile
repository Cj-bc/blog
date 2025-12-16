BRANCH_DEST := publish
SHELL := /usr/bin/bash
NPX := $(shell which npx)
GULP := $(NPX) gulp

# ---------- File dependencies ----------

css/node_modules:
	cd css && npm install

css/node_modules/fomantic-ui/src/theme.config: css/node_modules css/src/theme.config
	cp css/src/theme.config css/node_modules/fomantic-ui/src/theme.config

css/node_modules/fomantic-ui/semantic.json: css/node_modules css/semantic.json
	cp css/semantic.json css/node_modules/fomantic-ui/semantic.json

fomantic-ui-configs: css/node_modules/fomantic-ui/semantic.json css/node_modules/fomantic-ui/src/theme.config

fomantic-ui: fomantic-ui-configs
	cd css/node_modules/fomantic-ui && $(GULP) build

astro-ink/node_modules: astro-ink
	git submodule update --init
	cd astro-ink && npm install

# ---------- Commands ----------
test: blog-build

check: astro-ink/node_modules
	astro --version
	astro check

blog-build: astro-ink/node_modules
	shopt -s nullglob; cp posts/*.{org,md} astro-ink/src/content/blog/
	npm run build
	cp -r astro-ink/dist ./_site

blog-publish: blog-build
	git switch $(BRANCH_DEST)
	cp -a _site/. .
	git add -A
	git commit -m "auto commit: new build" || echo "Notice: no change has been occured. Nothing was committed"
	git switch -

pushExperiment:
	git branch experiment
	git push --force origin experiment
	git branch -d experiment
