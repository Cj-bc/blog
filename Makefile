BRANCH_DEST   := publish
HAKYLL_TARGET := blog

publish:
	make executeHakyll HAKYLL_TARGET=blog


pushExperiment:
	git branch experiment
	git push --force origin experiment
	git branch -d experiment

zenn:
	make executeHakyll HAKYLL_TARGET=zenn


# For internal use
executeHakyll:
	stack build $(HAKYLL_TARGET)
	stack exec $(HAKYLL_TARGET) rebuild
	git switch $(BRANCH_DEST)
	cp -a _site/. .
	git add -A
	git commit -m "auto commit: new build" || echo "Notice: no change has been occured. Nothing was committed"
	git switch -
