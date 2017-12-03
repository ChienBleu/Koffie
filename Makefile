install-conda:
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
	bash Miniconda3-latest-Linux-x86_64.sh
	##
	echo -n 'ENVS_PATH = ' > personal_info.py
	echo -n '"' >> personal_info.py
	conda info | grep "envs directories" | cut -d':' -f 2 | cut -d' ' -f 2 >> personal_info.py
	truncate -s -1 personal_info.py
	echo '"' >> personal_info.py
	echo -n 'WDIR = ' >> personal_info.py 
	echo -n '"' >> personal_info.py
	pwd >> personal_info.py
	truncate -s -1 personal_info.py
	echo '"' >> personal_info.py
	##
	echo '#!/bin/bash' > install-tools.sh
	echo -n 'source ' >> install-tools.sh
	conda info | grep "root environment" | cut -d':' -f 2 | cut -d' ' -f 2 >> install-tools.sh
	truncate -s -1 install-tools.sh
	echo '/bin/activate gtftk; cd gtftk; make install; conda install -c bioconda cpat ' >> install-tools.sh
	

install-tools:
	tar xvfz gtftk.tar.gz
	cd gtftk; conda env create -n gtftk -f conda/env.yaml
	./install-tools.sh
	
