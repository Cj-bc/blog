BRANCH_DEST := publish
GULP := gulp

css:
	cd css && $(GULP) build

publish: css
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
