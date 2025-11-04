BRANCH_DEST := publish
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

# ---------- Commands ----------
blog-build:
	git submodule update --init
	cp posts/*.org astro-ink/src/content/blog/
	cp posts/*.md astro-ink/src/content/blog/
	cd astro-ink && npm install && npm run build
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
