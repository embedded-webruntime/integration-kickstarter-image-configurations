
all: ks

ks:
	kickstarter -c configurations.yaml -r repos.yaml --outdir=kickstarts/

clean:
	rm -f */*~ */*/*~
	rm -rf kickstarts/
