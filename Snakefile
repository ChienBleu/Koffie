# Snakefile de comparaison des splicing sites de 3 classes de transcirts (LincRNA, protéines codantes et pseudogènes non procéssés) 
# Réalisé par Zacharie Ménétrier et Martin MESTDAGH 02/12/2017
##  pour lancer le workflow: snakemake Snakefile

from personal_info import WDIR

import subprocess

workdir: WDIR

# Chemin d'accès des différents répertoire des output intermédiaire
DATA_DIRECTORY = os.path.join(WDIR, "data")

# Attribution des espèces différentes
SPECIES = ["homo_sapiens", "mus_musculus"]
# Attribution des classes de transcrits
BIOTYPES = ["lincRNA", "protein_coding", "unprocessed_pseudogene"]


rule final:
    input: expand(DATA_DIRECTORY + "/logos/{biotypes}/{species}.pdf", species = SPECIES, biotypes = BIOTYPES)


# Règle de création de weblogo de chaque classes de transcrits des espèces
rule weblogo:
    input: DATA_DIRECTORY + "/sequences/segments/{biotypes}/{species}.fa"
    output: DATA_DIRECTORY + "/logos/{biotypes}/{species}.pdf"
    shell: """
    weblogo -f {input} -o {output} -F pdf
    """

# Règle de transformation des fichiers bed en fichiers fasta
rule fasta_from_bed:
    input: bed = DATA_DIRECTORY + "/genomic_regions/segments/{biotypes}/{species}.bed",
           fa = DATA_DIRECTORY + "/sequences/whole_genome/{species}.fa"
    output: DATA_DIRECTORY + "/sequences/segments/{biotypes}/{species}.fa"
    shell: """
    fastaFromBed -fi {input.fa} -bed {input.bed} -fo {output}
    """

# Règle de téléchargement du génome de l'homme (sans les chromosomes sexuels) et décompression
rule download_hg38_genome:
    output: DATA_DIRECTORY + "/sequences/whole_genome/homo_sapiens.fa"
    shell: """
    for i in $(seq 1 22) X Y ;do  curl http://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr$i.fa.gz | gunzip -c >> {output}; done
    """

# Règle de téléchargement du génome de la souris (sans les chromosomes sexuels) et décompression
rule download_mm10_genome:
    output: DATA_DIRECTORY + "/sequences/whole_genome/mus_musculus.fa"
    shell: """
    for i in $(seq 1 19) X Y ;do  curl http://hgdownload.soe.ucsc.edu/goldenPath/mm10/chromosomes/chr$i.fa.gz | gunzip -c >> {output}; done
    """

# Règle d'extension en 5' et 3' de 15 nucléotides pour chaque transcrits des 2 espèces
rule slop_bed:
    input: txt = DATA_DIRECTORY + "/chromosome_info/{species}.txt",
           gtf = DATA_DIRECTORY + "/genomic_regions/splitted/splicing/{biotypes}/{species}.gtf"
    output: DATA_DIRECTORY + "/genomic_regions/segments/{biotypes}/{species}.bed"
    shell: """
    slopBed -b 15 -g {input.txt} -i {input.gtf} > {output}
    """

# Règle de téléchargement des fichiers d'informations chromosomiques par espèces et décompression
rule download_slop_bed:
    output: homo = DATA_DIRECTORY + "/chromosome_info/homo_sapiens.txt",
            mus = DATA_DIRECTORY + "/chromosome_info/mus_musculus.txt"
    shell: """
    curl http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/chromInfo.txt.gz | gunzip -c > {output.homo}
    curl http://hgdownload.soe.ucsc.edu/goldenPath/mm10/database/chromInfo.txt.gz | gunzip -c > {output.mus}
    """

# Règle de récupération des sites de splicing des transcrits LincRNA
rule splicing_site_lincRNA:
    input: DATA_DIRECTORY + "/genomic_regions/lincRNAspecific/final/{species}.gtf"
    output: DATA_DIRECTORY + "/genomic_regions/splitted/splicing/lincRNA/{species}.gtf"
    shell: """
    gtftk splicing_site -i {input} -o {output}
    """

# Règle de récupération des sites de splicing des 2 classes de transcrits autres que LincRNA
rule splicing_site_others:
    input: DATA_DIRECTORY + "/genomic_regions/splitted/trimmed/{biotypes,(?!.*lincRNA).*}/{species}.gtf"
    output: DATA_DIRECTORY + "/genomic_regions/splitted/splicing/{biotypes,(?!.*lincRNA).*}/{species}.gtf"
    shell: """
    gtftk splicing_site -i {input} -o {output}
    """

# Règle de sélection des transcrits inférieur à 0.2
# Fin du traitement spécial aux transcrits LincRNA
rule select_cpat:
    input: DATA_DIRECTORY + "/genomic_regions/lincRNAspecific/cut/{species}.gtf"
    output: DATA_DIRECTORY + "/genomic_regions/lincRNAspecific/final/{species}.gtf"
    shell: """
    gtftk select_by_numeric_value -n '.' -i {input} -t "coding_pot < 0.2" -o {output}
    """

# Règle de chargement des résultats cpat
rule join_cpat:
    input: gtf = DATA_DIRECTORY + "/genomic_regions/lincRNAspecific/trimmed/{species}.gtf",
           txt = DATA_DIRECTORY + "/coding_pot_inputs/cut/{species}.txt"
    output: DATA_DIRECTORY + "/genomic_regions/lincRNAspecific/cut/{species}.gtf"
    shell: """
    gtftk join_attr -i {input.gtf} -k transcript_id -H -n coding_pot -j {input.txt} -o {output} -V 2
    """

# Règle de découpage fichiers cpat
rule cut_cpat:
    input: DATA_DIRECTORY + "/coding_pot_inputs/uncut/{species}.txt"
    output: DATA_DIRECTORY + "/coding_pot_inputs/cut/{species}.txt"
    shell: """
    cut -f 1,5 {input} > {output}
    """

# Règle de calcul du potentiel codant 
rule cpat:
    input: fa = DATA_DIRECTORY + "/coding_pot_inputs/{species}90_tx_seq.fa.gz",
           tsv = DATA_DIRECTORY + "/coding_pot_inputs/{species}_Hexamer.tsv",
           RData = DATA_DIRECTORY + "/coding_pot_inputs/{species}_logitModel.RData",
           lincRNA = DATA_DIRECTORY + "/genomic_regions/lincRNAspecific/trimmed/{species}.gtf"
    output: DATA_DIRECTORY + "/coding_pot_inputs/uncut/{species}.txt"
    threads: 6
    shell:"""
    cpat.py -g {input.fa} -o {output} -x {input.tsv} -d {input.RData}
    """
    
# Règle de téléchargement des hexamer.tsv et logitModel.RData pour calculer le potentiel codant
rule donwload_for_cpat:
    output: fa = DATA_DIRECTORY + "/coding_pot_inputs/{species}90_tx_seq.fa.gz",
            tsv = DATA_DIRECTORY + "/coding_pot_inputs/{species}_Hexamer.tsv",
            RData = DATA_DIRECTORY + "/coding_pot_inputs/{species}_logitModel.RData"
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
    input: DATA_DIRECTORY + "/genomic_regions/splitted/trimmed/lincRNA/{species}.gtf"
    output: DATA_DIRECTORY + "/genomic_regions/lincRNAspecific/trimmed/{species}.gtf"
    threads: 4
    shell: """
    gtftk select_by_tx_size -i {input} -m 200 -o {output}
    """

# Règle de sélection des transcrits avec au moins 2 exons
rule trim_by_nb_exon:
    input: DATA_DIRECTORY + "/genomic_regions/splitted/raw/{biotypes}/{species}.gtf"
    output: DATA_DIRECTORY + "/genomic_regions/splitted/trimmed/{biotypes}/{species}.gtf"
    threads: 4
    shell: """
    gtftk select_by_nb_exon -m 2 -i {input} -o {output}
    """

# Règle de sélection des 3 classes de transcrits
rule split_by_biotype:
    input: DATA_DIRECTORY + "/genomic_regions/MTfree/{species}.gtf"
    output: DATA_DIRECTORY + "/genomic_regions/splitted/raw/{biotypes}/{species}.gtf"
    threads: 4
    shell: """
    gtftk select_by_key -k transcript_biotype -i {input} -v {wildcards.biotypes} -o {output}
    """

# Règle pour retirer le chromosome mitochondrial
rule remove_mitochondrial_chromosome:
    input: DATA_DIRECTORY + "/genomic_regions/raw/{species}.gtf"
    output: DATA_DIRECTORY + "/genomic_regions/MTfree/{species}.gtf"
    threads: 4
    shell: """
    gtftk select_by_key -k chrom -i {input} -v MT -n -o {output} -C
    """

# Règle de décompression des fichiers d'espèces
rule gunzip_genomic_regions:
    input: DATA_DIRECTORY + "/genomic_regions/raw/{species}.gtf.gz"
    output: DATA_DIRECTORY + "/genomic_regions/raw/{species}.gtf"
    shell: """
    gunzip -c {input} > {output}
    """

# Règle de téléchargement des fichiers d'espèces
rule retrieve_species:
    output: DATA_DIRECTORY + "/genomic_regions/raw/{species}.gtf.gz"
    shell: """
    gtftk retrieve -s {wildcards.species} -o {output}
    """
