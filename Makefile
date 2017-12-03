install-conda:
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
	bash Miniconda3-latest-Linux-x86_64.sh

install-tools:
	tar xvfz gtftk.tar.gz
	cd gtftk; conda env create -n gtftk -f conda/env.yaml
	./install-gtftk.sh

download-inputs:
	./download-species.sh
	
