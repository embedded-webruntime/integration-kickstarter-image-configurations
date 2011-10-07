
all: meego

meego:
	@echo "Creating MeeGo based .ks files."
	kickstarter -c configs/MeeGo/configurations.yaml -r configs/MeeGo/repos.yaml --outdir=kickstarts/

clean:
	rm -f */*~ */*/*~
	rm -rf kickstarts/
