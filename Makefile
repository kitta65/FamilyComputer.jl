.PHONY: test
test:
	julia -e 'using Pkg; Pkg.activate("."); Pkg.test("FamilyComputer")'

.PHONY: setup
setup:
	julia -e 'using Pkg; Pkg.add(PackageSpec(name="JuliaFormatter", uuid="98e50ef6-434e-11e9-1051-2b60c6c9e899"))'

.PHONY: fmt
fmt: setup
	julia -e 'using JuliaFormatter; format(".")'
