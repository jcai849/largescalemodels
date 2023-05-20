install:
	R CMD INSTALL .
test-lm:
	cd inst/dev-tests && ./interactive-test.sh lm
test-glm:
	cd inst/dev-tests && ./interactive-test.sh glm
test-lasso:
	cd inst/dev-tests && ./interactive-test.sh lasso