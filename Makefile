install:
	make install-conda
	make create-personal-info
	make install-tools

install-conda:
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
	bash Miniconda3-latest-Linux-x86_64.sh

create-personal-info:
	echo -n 'WDIR = "' > personal_info.py
	pwd >> personal_info.py
	truncate -s -1 personal_info.py
	echo '"' >> personal_info.py

install-tools:
	tar xvfz gtftk.tar.gz
	cd gtftk; conda env create -n gtftk -f conda/env.yaml
	chmod +x install-tools.sh; bash install-tools.sh
