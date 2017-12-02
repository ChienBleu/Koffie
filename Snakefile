from personal_info import WDIR
from personal_info import ENVS_PATH
import subprocess

workdir: WDIR


GTFTK_ACTIVATE = "source " + ENVS_PATH + "gtftk/bin/activate gtftk"
CPAT_ACTIVATE = "source " + ENVS_PATH + "cpat/bin/activate cpat"

GTF_DATA_DIRECTORY = os.path.join(WDIR, "gtf_data")
CPAT_DATA_DIRECTORY = os.path.join(WDIR, "cpat_data")
BED_DATA_DIRECTORY = os.path.join(WDIR, "bed_data")
FASTA_DATA_DIRECTORY = os.path.join(WDIR, "fasta_data")

SPECIES = ["homo_sapiens", "mus_musculus"]
OTHERS_SPECIES = ["hg38", "mm10"]
BIOTYPES = ["lincRNA", "protein_coding", "unprocessed_pseudogene"]
BIOTYPES_OTHERS = ["protein_coding", "unprocessed_pseudogene"]

rule final:
    input: expand(FASTA_DATA_DIRECTORY + "/{species}-{biotypes}.fa", species = SPECIES, biotypes = BIOTYPES)

rule fasta_from_bed:
    input: bed = BED_DATA_DIRECTORY + "/{species}-{biotypes}.bed",
           fa = FASTA_DATA_DIRECTORY + "/whole_genome/{species}.fa"
    output: FASTA_DATA_DIRECTORY + "/{species}-{biotypes}.fa"
    shell: """
    fastaFromBed -fi {input.fa} -bed {input.bed} -fo {output}
    """

rule download_hg38_genome:
    output: FASTA_DATA_DIRECTORY + "/whole_genome/homo_sapiens.fa"
    shell: """
    for i in $(seq 1 22) X Y ;do  curl http://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr$i.fa.gz | gunzip -c >> {output}; done
    """

rule download_mm10_genome:
    output: FASTA_DATA_DIRECTORY + "/whole_genome/mus_musculus.fa"
    shell: """
    for i in $(seq 1 19) X Y ;do  curl http://hgdownload.soe.ucsc.edu/goldenPath/mm10/chromosomes/chr$i.fa.gz | gunzip -c >> {output}; done
    """

rule slop_bed:
    input: txt = BED_DATA_DIRECTORY + "/{species}.txt",
           gtf = GTF_DATA_DIRECTORY + "/spliced/{species}-{biotypes}.gtf"
    output: BED_DATA_DIRECTORY + "/{species}-{biotypes}.bed"
    shell: """
    slopBed -b 15 -g {input.txt} -i {input.gtf} > {output}
    """

rule download_slop_bed:
    output: homo = BED_DATA_DIRECTORY + "/homo_sapiens.txt",
            mus = BED_DATA_DIRECTORY + "/mus_musculus.txt",
    params: homo = BED_DATA_DIRECTORY + "/homo_sapiens.txt.gz",
            mus = BED_DATA_DIRECTORY + "/mus_musculus.txt.gz",
    shell: """
    wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/chromInfo.txt.gz -O {params.homo}
    wget http://hgdownload.soe.ucsc.edu/goldenPath/mm10/database/chromInfo.txt.gz -O {params.mus}
    gunzip {params.homo}
    gunzip {params.mus}
    """

rule splicing_site_lincRNA:
    input: GTF_DATA_DIRECTORY + "/cpat/{species}-lincRNA-200nt-codpot-c1,5-0,2.gtf"
    output: GTF_DATA_DIRECTORY + "/spliced/{species}-lincRNA.gtf"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk splicing_site -i {input} -o {output}
    """

rule splicing_site_others:
    input: GTF_DATA_DIRECTORY + "/trimmed/{species}-{biotypes_others,(?!.*lincRNA).*}.gtf"
    output: GTF_DATA_DIRECTORY + "/spliced/{species}-{biotypes_others,(?!.*lincRNA).*}.gtf"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk splicing_site -i {input} -o {output}
    """


rule select_cpat:
    input: GTF_DATA_DIRECTORY + "/cpat/{species}-lincRNA-200nt-codpot-c1,5.gtf"
    output: GTF_DATA_DIRECTORY + "/cpat/{species}-lincRNA-200nt-codpot-c1,5-0,2.gtf"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_numeric_value -n '.' -i {input} -t "coding_pot < 0.2" -o {output}
    """

rule join_cpat:
    input: gtf = GTF_DATA_DIRECTORY + "/trimmed/{species}-lincRNA.gtf",
           txt = CPAT_DATA_DIRECTORY + "/{species}-lincRNA-200nt-codpot-c1,5.txt"
    output: GTF_DATA_DIRECTORY + "/cpat/{species}-lincRNA-200nt-codpot-c1,5.gtf"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk join_attr -i {input.gtf} -k transcript_id -H -n coding_pot -j {input.txt} -o {output} -V 2
    """


rule cut_cpat:
    input: CPAT_DATA_DIRECTORY + "/{species}-lincRNA-200nt-codpot.txt"
    output: CPAT_DATA_DIRECTORY + "/{species}-lincRNA-200nt-codpot-c1,5.txt"
    shell: """
    cut -f 1,5 {input} > {output}
    """


rule cpat:
    input: fa = CPAT_DATA_DIRECTORY + "/{species}90_tx_seq.fa.gz",
           tsv = CPAT_DATA_DIRECTORY + "/{species}_Hexamer.tsv",
           RData = CPAT_DATA_DIRECTORY + "/{species}_logitModel.RData",
           lincRNA = GTF_DATA_DIRECTORY + "/lincRNA-200nt/{species}-lincRNA-200nt.gtf"
    output: CPAT_DATA_DIRECTORY + "/{species}-lincRNA-200nt-codpot.txt"
    threads: 6
    params: cpat_activate = CPAT_ACTIVATE
    shell:"""
    {params.cpat_activate}
    cpat.py -g {input.fa} -o {output} -x {input.tsv} -d {input.RData}
    """
    

rule donwload_for_cpat:
    output: fa = CPAT_DATA_DIRECTORY + "/{species}90_tx_seq.fa.gz",
            tsv = CPAT_DATA_DIRECTORY + "/{species}_Hexamer.tsv",
            RData = CPAT_DATA_DIRECTORY + "/{species}_logitModel.RData"
    threads: 3
    params: url = "http://zacharie.menetier.etu.myspace.luminy.univ-amu.fr/"
    shell: """
    wget {params.url}{wildcards.species}90_tx_seq.fa.gz -O {output.fa}
    wget {params.url}{wildcards.species}_Hexamer.tsv -O {output.tsv}
    wget {params.url}{wildcards.species}_logitModel.RData -O {output.RData}
    """


rule trim_lincRNA:
    input: GTF_DATA_DIRECTORY + "/trimmed/{species}-lincRNA.gtf"
    output: GTF_DATA_DIRECTORY + "/lincRNA-200nt/{species}-lincRNA-200nt.gtf"
    threads: 4
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_tx_size -i {input} -m 200 -o {output}
    """


rule trim_nb_exon:
    input: GTF_DATA_DIRECTORY + "/splitted/{species}-{biotypes}.gtf"
    output: GTF_DATA_DIRECTORY + "/trimmed/{species}-{biotypes}.gtf"
    threads: 4
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_nb_exon -m 2 -i {input} -o {output}
    """


rule split_select:
    input: GTF_DATA_DIRECTORY + "/nucleus/{species}.gtf"
    output: GTF_DATA_DIRECTORY + "/splitted/{species}-{biotypes}.gtf"
    threads: 4
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_key -k transcript_biotype -i {input} -v {wildcards.biotypes} -o {output}
    """


rule remove_mitochondrial_chromosome:
    input: GTF_DATA_DIRECTORY + "/raw/{species}.gtf"
    output: GTF_DATA_DIRECTORY + "/nucleus/{species}.gtf"
    threads: 4
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
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
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk retrieve -s {wildcards.species} -o {output}
    """





