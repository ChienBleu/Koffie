from personal_info import WDIR
import subprocess

workdir: WDIR

GTF_DATA_DIRECTORY = os.path.join(WDIR, "gtf_data")
SPECIES = ["homo_sapiens", "mus_musculus"]
BIOTYPES = ["lincRNA", "protein_coding", "unprocessed_pseudogene"]

rule final:
    input:  expand(GTF_DATA_DIRECTORY + "/{species}_nucleus_{biotypes}.gtf", species = SPECIES, biotypes = BIOTYPES)

rule split_select:
    input: GTF_DATA_DIRECTORY + "/{species}_nucleus.gtf"
    output: GTF_DATA_DIRECTORY + "/{species}_nucleus_{biotypes}.gtf"
    threads: 4
    shell:"""
    gtftk select_by_key -k transcript_biotype -i {input} -v {wildcards.biotypes} -o {output[0]}
    """

rule remove_mitochondrial_chromosome:
    input: GTF_DATA_DIRECTORY + "/{species}_raw.gtf"
    output: GTF_DATA_DIRECTORY + "/{species}_nucleus.gtf"
    threads: 4
    shell: """
    gtftk select_by_key -k chrom -i {input} -v MT -n -o {output} -C
    """

rule gunzip_files:
    input: GTF_DATA_DIRECTORY + "/{species}_raw.gtf.gz"
    output: GTF_DATA_DIRECTORY + "/{species}_raw.gtf"
    shell: """
    gunzip -c {input} > {output}
    """

rule download:
    output: GTF_DATA_DIRECTORY + "/{species}_raw.gtf.gz"
    shell: """
    gtftk retrieve -s {wildcards.species} -o {output}
    """





