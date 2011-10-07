
all: meego mer

meego:
	@echo "Creating MeeGo based .ks files."
	kickstarter -c configs/MeeGo/configurations.yaml -r configs/MeeGo/repos.yaml --outdir=kickstarts/

mer:
	@echo "Creating Mer based .ks files."
	kickstarter -c configs/Mer/configurations.yaml -r configs/Mer/repos.yaml --outdir=kickstarts/

clean:
	rm -f */*~ */*/*~
	rm -rf kickstarts/
