from personal_info import WDIR
import subprocess

workdir: WDIR

GTF_DATA_DIRECTORY = os.path.join(WDIR, "gtf_data")
SPECIES = ["homo_sapiens", "mus_musculus"]
BIOTYPES = ["lincRNA", "protein_coding", "unprocessed_pseudogene"]



rule final:
    input:  expand(GTF_DATA_DIRECTORY + "/trimmed/{species}-{biotypes}.gtf", species = SPECIES, biotypes = BIOTYPES),
            expand(GTF_DATA_DIRECTORY + "/lincRNA/{species}-lincRNA.gtf", species = SPECIES)


rule lincRNA:
    input: GTF_DATA_DIRECTORY + "/trimmed/{species}-lincRNA.gtf"
    output: GTF_DATA_DIRECTORY + "/lincRNA/{species}-lincRNA.gtf"
    conda: "envs/gtftk.yaml"
    shell:"""
    set +u; source /homes/m2_2017_abd_menetrier/miniconda3/envs/gtftk/bin/activate gtftk; set -u
    gtftk select_by_tx_size -i {input} -m 200 -o {output}
    """

rule trim_nb_exon:
    input: GTF_DATA_DIRECTORY + "/splitted/{species}-{biotypes}.gtf"
    output: GTF_DATA_DIRECTORY + "/trimmed/{species}-{biotypes}.gtf"
    conda: "envs/ggplot.yaml"
    threads: 4
    shell:"""
    set +u; source /homes/m2_2017_abd_menetrier/miniconda3/envs/gtftk/bin/activate gtftk; set -u
    gtftk select_by_nb_exon -m 2 -i {input} -o {output}
    """

rule split_select:
    input: GTF_DATA_DIRECTORY + "/nucleus/{species}.gtf"
    output: GTF_DATA_DIRECTORY + "/splitted/{species}-{biotypes}.gtf"
    threads: 4
    shell:"""
    set +u; source /homes/m2_2017_abd_menetrier/miniconda3/envs/gtftk/bin/activate gtftk; set -u
    gtftk select_by_key -k transcript_biotype -i {input} -v {wildcards.biotypes} -o {output}
    """

rule remove_mitochondrial_chromosome:
    input: GTF_DATA_DIRECTORY + "/raw/{species}.gtf"
    output: GTF_DATA_DIRECTORY + "/nucleus/{species}.gtf"
    threads: 4
    shell: """
    set +u; source /homes/m2_2017_abd_menetrier/miniconda3/envs/gtftk/bin/activate gtftk; set -u
    gtftk select_by_key -k chrom -i {input} -v MT -n -o {output} -C
    """

rule gunzip_files:
    input: GTF_DATA_DIRECTORY + "/raw/{species}.gtf.gz"
    output: GTF_DATA_DIRECTORY + "/raw/{species}.gtf"
    shell: """
    gunzip -c {input} > {output}
    """

rule download:
    output: GTF_DATA_DIRECTORY + "/raw/{species}.gtf.gz"
    shell: """
    set +u; source /homes/m2_2017_abd_menetrier/miniconda3/envs/gtftk/bin/activate gtftk; set -u
    gtftk retrieve -s {wildcards.species} -o {output}
    """





