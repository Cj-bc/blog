publish:
	git switch source
	stack build
	stack exec blog rebuild
	git switch publish
	cp -a _site/. .
	git add -A
	git commit -m "auto commit: new build" || echo "Notice: no change has been occured. Nothing was committed"
	git switch source



