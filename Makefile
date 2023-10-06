.PHONY: test
test:
	julia -e 'using Pkg; Pkg.activate("."); Pkg.test("FamilyComputer")'

.PHONY: setup
setup: download
	julia -e 'using Pkg; Pkg.add(PackageSpec(name="JuliaFormatter", uuid="98e50ef6-434e-11e9-1051-2b60c6c9e899"))'

.PHONY: fmt
fmt: setup
	julia -e 'using JuliaFormatter; format(".")'

.PHONY: download
download: download/nestest.nes download/nestest.log

download/nestest.nes:
	curl -L --output download/nestest.nes https://nickmass.com/images/nestest.nes

download/nestest.log:
	curl -L --output download/nestest.log https://nickmass.com/images/nestest.log
