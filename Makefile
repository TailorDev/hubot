default: test

boostrap:
	@scripts/bootstrap

test:
	@scripts/test

.PHONY: bootstrap test
