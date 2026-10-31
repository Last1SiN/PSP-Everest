# Build each PRX dependency before the app; GNU Make stops at first failure.
.PHONY: all clean

all:
	$(MAKE) -C plugin/kernel
	$(MAKE) -C plugin/kumdman
	$(MAKE) -C app

clean:
	$(MAKE) clean -C app
	$(MAKE) clean -C plugin/kumdman
	$(MAKE) clean -C plugin/kernel
