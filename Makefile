BRANCH_DEST := publish
NPX := $(shell which npx)
GULP := $(NPX) gulp

css/node_modules/highlight.js: css/node_modules

css/dist/semantic.min.css: css/node_modules
	cd css && $(GULP) build

css/dist/semantic.min.js: css/node_modules
	cd css && $(GULP) build

css/node_modules:
	cd css && npm install


build: css/dist/semantic.min.css css/dist/semantic.min.js css/node_modules/highlight.js
	stack build
	stack exec blog rebuild


publish: build
	git switch $(BRANCH_DEST)
	cp -a _site/. .
	git add -A
	git commit -m "auto commit: new build" || echo "Notice: no change has been occured. Nothing was committed"
	git switch -


pushExperiment:
	git branch experiment
	git push --force origin experiment
	git branch -d experiment
