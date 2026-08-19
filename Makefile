.PHONY: check project-check test

check: test project-check

test:
	@swift test -Xswiftc -warnings-as-errors

project-check:
	@./scripts/check-project.sh
