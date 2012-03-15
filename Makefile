
all: nemo

nemo:
	@echo "Creating Nemo .ks files."
	kickstarter -c configs/Nemo/configurations.yaml -r configs/Nemo/repos.yaml --outdir=kickstarts/

nemo-next:
	@echo "Creating Nemo Next .ks files."
	kickstarter -c configs/Nemo/configurations.yaml -r configs/Nemo/repos-next.yaml --outdir=kickstarts-next/

clean:
	rm -f */*~ */*/*~

