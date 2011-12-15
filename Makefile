
all: meego nemo

meego:
	@echo "Creating MeeGo based .ks files."
	kickstarter -c configs/MeeGo/configurations.yaml -r configs/MeeGo/repos.yaml --outdir=kickstarts/

nemo:
	@echo "Creating Nemo .ks files."
	kickstarter -c configs/Nemo/configurations.yaml -r configs/Nemo/repos.yaml --outdir=kickstarts/

clean:
	rm -f */*~ */*/*~

