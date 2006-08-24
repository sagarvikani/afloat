EXTRA_LANGS=
LANGS=en it zh-tw pl $(EXTRA_LANGS)

show: all
	open ../Work/*.html

all: workdir
	cp -rv . ../Work/
	rm ../Work/Makefile
	rm -rf ../Work/Templates
	cd ../Work && ../WorkTools/Pagepress/Pagepress ../Website/Templates/index.tpl $(LANGS)
	
workdir:
	@test \! -e ../Work || (echo "** The 'Work' directory already exists. Delete it (or do a make clean) and try again." && exit 1)
	mkdir ../Work
	
clean:
	rm -rf ../Work