publish:
	git switch source
	stack build
	stack exec blog rebuild
	git switch publish
	cp -a _site/. .
	git add -A
	git commit -m "auto commit: new article"
	git switch source



