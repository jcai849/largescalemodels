install:
	R CMD INSTALL .
test-lm:
	cd tests && ./interactive-test.sh lm
test-glm:
	cd tests && ./interactive-test.sh glm
test-lasso:
	cd tests && ./interactive-test.sh lasso