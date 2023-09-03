.PHONY: test
test:
	julia -e 'using Pkg; Pkg.activate("."); Pkg.test("FamilyComputer")'
