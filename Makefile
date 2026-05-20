BRANCH_DEST := publish
SHELL := /usr/bin/bash
NPX := $(shell which npx)

# ---------- File dependencies ----------

astro-ink/node_modules: astro-ink
	git submodule update --init
	cd astro-ink && npm install

# ---------- Commands ----------
test: blog-build

check: astro-ink/node_modules
	cd astro-ink && npx astro --version
	cd astro-ink && npm run check

blog-build: astro-ink/node_modules
	shopt -s nullglob; cp posts/*.{org,md} astro-ink/src/content/blog/
	cd astro-ink && npm run build
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
