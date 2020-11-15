BRANCH_DEST := publish
NPX := $(shell which npx)
GULP := $(NPX) gulp

css/dist/semantic.min.css:
	cd css && $(GULP) build

css/dist/semantic.min.js:
	cd css && $(GULP) build


publish: css/dist
	stack build
	stack exec blog rebuild
	git switch $(BRANCH_DEST)
	cp -a _site/. .
	git add -A
	git commit -m "auto commit: new build" || echo "Notice: no change has been occured. Nothing was committed"
	git switch -


pushExperiment:
	git branch experiment
	git push --force origin experiment
	git branch -d experiment
