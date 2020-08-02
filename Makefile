publish:
	git switch source
	stack build
	stack exec blog rebuild
	git switch publish
	mv _site/* .
	git add .
	git commit -m "auto commit: new article"
	git switch source



