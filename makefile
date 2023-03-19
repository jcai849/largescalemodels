install:
	R CMD INSTALL .
test-lm:
	cd tests && ./interactive-test.sh lm
test-glm:
	cd tests && ./interactive-test.sh glm