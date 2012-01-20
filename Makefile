
all: nemo

nemo:
	@echo "Creating Nemo .ks files."
	kickstarter -c configs/Nemo/configurations.yaml -r configs/Nemo/repos.yaml --outdir=kickstarts/

clean:
	rm -f */*~ */*/*~

