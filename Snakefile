# Snakefile de comparaison des splicing sites de 3 classes de transcirts (LincRNA, protéines codantes et pseudogènes non procéssés) 
# Réalisé par Zacharie Ménétrier et Martin MESTDAGH 02/12/2017
##  pour lancer le workflow: snakemake Snakefile


from personal_info import WDIR
from personal_info import ENVS_PATH
import subprocess

workdir: WDIR

# Chemin d'accès aux environnements pour les différentes actiions
GTFTK_ACTIVATE = "source " + ENVS_PATH + "gtftk/bin/activate gtftk"
CPAT_ACTIVATE = "source " + ENVS_PATH + "cpat/bin/activate cpat"

# Chemin d'accès des différents répertoire des output intermédiaire
GTF_DATA_DIRECTORY = os.path.join(WDIR, "gtf_data")
CPAT_DATA_DIRECTORY = os.path.join(WDIR, "cpat_data")
BED_DATA_DIRECTORY = os.path.join(WDIR, "bed_data")
FASTA_DATA_DIRECTORY = os.path.join(WDIR, "fasta_data")
WEBLOGO_DIRECTORY = os.path.join(WDIR, "web_logo")

# Attribution des espèces différentes
SPECIES = ["homo_sapiens", "mus_musculus"]
# Attribution du diminutif des espèces différentes
OTHERS_SPECIES = ["hg38", "mm10"]
# Attribution des classes de transcrits
BIOTYPES = ["lincRNA", "protein_coding", "unprocessed_pseudogene"]
# Attribution des classes de transcrits n'ayant pas de traitement spécifique
BIOTYPES_OTHERS = ["protein_coding", "unprocessed_pseudogene"]


rule final:
    input: expand(WEBLOGO_DIRECTORY + "/{species}-{biotypes}.pdf", species = SPECIES, biotypes = BIOTYPES)


# Règle de création de weblogo de chaque classes de transcrits des espèces
rule weblogo:
    input: FASTA_DATA_DIRECTORY + "/{species}-{biotypes}.fa"
    output: WEBLOGO_DIRECTORY + "/{species}-{biotypes}.pdf"
    shell: """
    weblogo -f {input} -o {output} -F pdf
    """

# Règle de transformation des fichiers bed en fichiers fasta
rule fasta_from_bed:
    input: bed = BED_DATA_DIRECTORY + "/{species}-{biotypes}.bed",
           fa = FASTA_DATA_DIRECTORY + "/whole_genome/{species}.fa"
    output: FASTA_DATA_DIRECTORY + "/{species}-{biotypes}.fa"
    shell: """
    fastaFromBed -fi {input.fa} -bed {input.bed} -fo {output}
    """

# Règle de téléchargement du génome de l'homme (sans les chromosomes sexuels) et décompression
rule download_hg38_genome:
    output: FASTA_DATA_DIRECTORY + "/whole_genome/homo_sapiens.fa"
    shell: """
    for i in $(seq 1 22) X Y ;do  curl http://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr$i.fa.gz | gunzip -c >> {output}; done
    """

# Règle de téléchargement du génome de la souris (sans les chromosomes sexuels) et décompression
rule download_mm10_genome:
    output: FASTA_DATA_DIRECTORY + "/whole_genome/mus_musculus.fa"
    shell: """
    for i in $(seq 1 19) X Y ;do  curl http://hgdownload.soe.ucsc.edu/goldenPath/mm10/chromosomes/chr$i.fa.gz | gunzip -c >> {output}; done
    """

# Règle d'extension en 5' et 3' de 15 nucléotides pour chaque transcrits des 2 espèces
rule slop_bed:
    input: txt = BED_DATA_DIRECTORY + "/{species}.txt",
           gtf = GTF_DATA_DIRECTORY + "/spliced/{species}-{biotypes}.gtf"
    output: BED_DATA_DIRde téléECTORY + "/{species}-{biotypes}.bed"
    shell: """
    slopBed -b 15 -g {input.txt} -i {input.gtf} > {output}
    """

# Règle de téléchargement des fichiers d'informations chromosomiques par espèces et décompression
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

# Règle de récupération des sites de splicing des transcrits LincRNA
rule splicing_site_lincRNA:
    input: GTF_DATA_DIRECTORY + "/cpat/{species}-lincRNA-200nt-codpot-c1,5-0,2.gtf"
    output: GTF_DATA_DIRECTORY + "/spliced/{species}-lincRNA.gtf"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk splicing_site -i {input} -o {output}
    """

# Règle de récupération des sites de splicing des 2 classes de transcrits autres que LincRNA
rule splicing_site_others:
    input: GTF_DATA_DIRECTORY + "/trimmed/{species}-{biotypes_others,(?!.*lincRNA).*}.gtf"
    output: GTF_DATA_DIRECTORY + "/spliced/{species}-{biotypes_others,(?!.*lincRNA).*}.gtf"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk splicing_site -i {input} -o {output}
    """

# Règle de sélection des transcrits inférieur à 0.2
# Fin du traitement spécial aux transcrits LincRNA
rule select_cpat:
    input: GTF_DATA_DIRECTORY + "/cpat/{species}-lincRNA-200nt-codpot-c1,5.gtf"
    output: GTF_DATA_DIRECTORY + "/cpat/{species}-lincRNA-200nt-codpot-c1,5-0,2.gtf"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_numeric_value -n '.' -i {input} -t "coding_pot < 0.2" -o {output}
    """

# Règle de chargement des résultats cpat
rule join_cpat:
    input: gtf = GTF_DATA_DIRECTORY + "/trimmed/{species}-lincRNA.gtf",
           txt = CPAT_DATA_DIRECTORY + "/{species}-lincRNA-200nt-codpot-c1,5.txt"
    output: GTF_DATA_DIRECTORY + "/cpat/{species}-lincRNA-200nt-codpot-c1,5.gtf"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk join_attr -i {input.gtf} -k transcript_id -H -n coding_pot -j {input.txt} -o {output} -V 2
    """

# Règle de découpage fichiers cpat
rule cut_cpat:
    input: CPAT_DATA_DIRECTORY + "/{species}-lincRNA-200nt-codpot.txt"
    output: CPAT_DATA_DIRECTORY + "/{species}-lincRNA-200nt-codpot-c1,5.txt"
    shell: """
    cut -f 1,5 {input} > {output}
    """

# Règle de calcul du potentiel codant 
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
    
# Règle de téléchargement des hexamer.tsv et logitModel.RData pour calculer le potentiel codant
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

# Règle de séléction des transcrits supérieur à 200 nucléotides
# Début du traitement spécifique aux transcrits LincRNA
rule trim_lincRNA:
    input: GTF_DATA_DIRECTORY + "/trimmed/{species}-lincRNA.gtf"
    output: GTF_DATA_DIRECTORY + "/lincRNA-200nt/{species}-lincRNA-200nt.gtf"
    threads: 4
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_tx_size -i {input} -m 200 -o {output}
    """

# Règle de sélection des transcrits avec au moins 2 exons
rule trim_nb_exon:
    input: GTF_DATA_DIRECTORY + "/splitted/{species}-{biotypes}.gtf"
    output: GTF_DATA_DIRECTORY + "/trimmed/{species}-{biotypes}.gtf"
    threads: 4
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_nb_exon -m 2 -i {input} -o {output}
    """

# Règle de sélection des 3 classes de transcrits
rule split_select:
    input: GTF_DATA_DIRECTORY + "/nucleus/{species}.gtf"
    output: GTF_DATA_DIRECTORY + "/splitted/{species}-{biotypes}.gtf"
    threads: 4
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_key -k transcript_biotype -i {input} -v {wildcards.biotypes} -o {output}
    """

# Règle pour retirer le chromosome mitochondrial
rule remove_mitochondrial_chromosome:
    input: GTF_DATA_DIRECTORY + "/raw/{species}.gtf"
    output: GTF_DATA_DIRECTORY + "/nucleus/{species}.gtf"
    threads: 4
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk select_by_key -k chrom -i {input} -v MT -n -o {output} -C
    """

# Règle de décompression des fichiers d'espèces
rule gunzip_files:
    input: GTF_DATA_DIRECTORY + "/raw/{species}.gtf.gz"
    output: GTF_DATA_DIRECTORY + "/raw/{species}.gtf"
    shell: """
    gunzip -c {input} > {output}
    """

# Règle de téléchargement des fichiers d'espèces
rule download:
    output: GTF_DATA_DIRECTORY + "/raw/{species}.gtf.gz"
    params: gtftk_activate = GTFTK_ACTIVATE
    shell: """
    {params.gtftk_activate}
    gtftk retrieve -s {wildcards.species} -o {output}
    """
