SUBDIRS = plugin/kernel plugin/kumdman app

all:
	@set -e; for dir in $(SUBDIRS); do $(MAKE) -C $dir; done

clean:
	@set -e; for dir in $(SUBDIRS); do $(MAKE) clean -C $dir; done
