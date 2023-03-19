install:
	R CMD INSTALL .
test:
	cd tests && ./interactive-test.sh