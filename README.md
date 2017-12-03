# Workflow de comparaison des sites d'épissages pour 3 classes de transcrits (LincRNA, protéines codantes et pseudogènes non procéssés) chez l'homme et chez la souris

#### Compte rendu Analyses bioinformatiques des données à haut débit M2BBSG 2017/2018 Denis Puthier et Aitor Gonzalez

## Zacharie Menetrier et Martin Mestdagh

#### Prérequis
Workflow effectué sur Linux X86 64 bits

### Contexte

D. Puthier et A. Gonzalez travaillent en collaboration avec F. Lopez sur le développement d’un programme permettant de manipuler des fichiers GTF (Gene transfer format). Le format GTF correspond à un fichier tabulé qui contient des informations concernant des éléments génomiques (souvent des gènes, transcrits et leurs exons).


### Objectif du workflow

Son objectif est de comparer les sites d'épissages de 3 classes de transcrits:  
	-	Gènes codants (protein_coding)  
	-	LincRNA (LincRNA)  
	-	Pseudogènes non procéssés (unprocessed_pseudogene)  

Le workflow va effectuer plusieurs manipulations sur les fichiers de format gtf tels que le retrait du chromosome mitochondrial, la sélection des classes de transcrits avec au moins 2 exons,(la classe de transcrits LincRNA a un traitement spécifique: séléction des transcrits de taille supérieur à 200 nucléotides puis choix des transcrits ayant un potentiel codant inférieur à O,2) pour l'obtention des sites d'épissages de ces derniers. Puis de récupérer un fichier format fasta pour obtenir un logo de ces sites.  
Il permet alors de pouvoir comparer des logos pour analyser les sites d'épissages des classes de transcrits.  
Le workflow obtient les sites d'épissages de deux organismes l'homme et la souris (hg38 release 90, mm10 release 90).  


### Réalisation
Le workflow a été réalisé sur les sessions personnels du serveur pedagogix du TAGC, par _Zacharie Ménétrier_ et _Martin Mestdagh_ durant l'unité d'enseignement Analyses bioinformatiques des données à haut débit enseigné par _Denis Puthier_ et _Aitor Gonzalez_ pendant l'année scolaire 2017/2018.  
Les logiciels utilisés sont:
- gtftk permettant de manipuler les fichiers de données gtf.
- cpat pour le calcul des potentiels codants des transcrits de la classe LincRNA
- bedTools pour l'élongation des séquences obtenus et la récupération des fichiers en format fasta.  
- Weblogo va permettre d'obtenir les logos de ces sites.

Le dossier contient les fichiers suivants :  
 	-	Makefile  
	-	README.md  
	-	Snakefile  
	-	install-tools.sh  

### A lire avant d'excécuter
Pour pouvoir utiliser le workflow, il faut tout d'abord lancer le fichier *Makefile*.  
Celui-ci se charge d'installer les outils nécessaires au lancement du workflow.s

Tout d'abord pour pouvoir lancer le makefile il vous faut le fichier compréssé **gtftk.tar.gz** que vous pouvez trouvez à l'adresse suivante:  
[gtftk.tar.gz](https://ametice.univ-amu.fr/pluginfile.php/1873547/mod_resource/content/2/gtftk.tar.gz).  
Enregistrez ce fichier compréssé dans le dossier où se trouve le fichier *Makefile* (cela permettra d'installer le logiciel gtftk nécéssaire au workflow).  
Pour les installations du fichier *Makefile* veuillez copier la ligne de commande suivante:  
	`make install`  
	**NB**: Pour cette installation il vous sera demandé de lire la license, de taper sur "ENTER" plusieurs fois pour ensuite confirmer (avec "yes" ou "y") d'avoir lu la license puis de suivre les instructions jusqu'à l'installation (veuillez choisir le même répertoire d'installation en tappant "ENTER" quand l'installation vous le demande).  

Si miniconda est déjà installé sur votre machine vous pouvez lancer à la place la commande:  
	`make install-tools` 

Maintenant veuillez activer l'environnement créé avec cette commande:  
	`source activate gtftk`  

A présent vous avez installé tous les éléments nécéssaires à l'utilisation du workflow. Le workflow peut-être lancé de deux façons différentes:  
	`snakemake`  
**OU** avec cette dernière permettant d'utiliser plusieurs threads en même temps (conseillé):  
	`snakemake -c 'qsub -V -q batch -l nodes=1:ppn={threads}' -j 10`  


### Conclusion
Les logo nécéssaires à la conclusion sont situés dans /data/logo/ triés par classes au format pdf.
Au regard des sites d'épissages obtenus pour chaque classes des deux espèces nous pouvons voir une forte ressemblance entre-eux mais aussi entre les espèces.  
A quoi servent ces sites d'épissages?  
l'épissage est un processus complexe produisant l'ARN messager nécéssite la reconnaissance des exons, l'excision des introns puis l'union des exons pour former un transcrit mature. Cette reconnaissance est assurée par des séquences consensus en cis (**les sites d'épissages**). Nous pouvons dire que ces sites d'épissages se conforment à une séquences consensus.  
En effet il est reconnu que des altérations de ces sites vont altérer la fonction de ces sites et donc altérer l'épissage.  

Pourquoi ces sites ont des séquences consensus?  
Il est bien établi que presque tous les sites d'épissage se conforment à des séquences consensus. Ces séquences consensus comprennent des dinucléotides presque invariants à chaque extrémité de l'intron, GT à l'extrémité 5 'de l'intron et AG à l'extrémité 3' de l'intron.  
Les séquences consensus du site d'épissage pour la classe majeure d'introns dans le pré-ARNm se conforment généralement aux séquences consensus suivantes:  
3 'sites d'épissage: CAG | G  
Sites d'épissage 5 ': MAG | GTRAGT où M est A ou C et R est A ou G  
(Wu et Krainer 1999, Thanaraj et Clark 2001).  

Mais que sont ces 3 classes de transcrits?  
Les 3 classes de transcrits sont les gènes codants, les pseudogènes non procéssés et les LincRNA. Pour cela revoyons les définitions de pseudogène non procéssé et de LincRNA:  
	-	Un pseudogène non procéssé correspond à un gène possédant encore ses introns issu d'une duplication génique (processus commun et important dans l'évolution des génomes).  
	-	Les LincRNA sont de longs ARN non codant intergéniques c'est-à-dire des transcrits d'ARN de grandes tailles. Beaucoup de ces transcrits sont codés par l'ARN polymérase II et sont épissés puis poly-adénylés. le terme "intergenique" se réfère à l'identification de ces transcrits à partir de régions du génome qui ne contiennent pas de gènes codant pour une protéine. Ces LincRNA faisaient partis de "l'ADN poubelle" de nos génomes alors que grâce aux nouvelles techniques et études minutieuses nous pouvons dire aujourd'hui que ces ARN codent clairement les transcrits d'ARN et ils contiennent également des ARN associés au promoteur ou au promoteur proches du gènes.
Ces trois classes des transcrits de protéines codants, de pseudogènes ayant des introns et des long ARN "non codant".  

**Pour conclure,** nous pouvons émettre l'hypothèse suivante: que ce soit des transcrits de protéines codantes, de pseudogènes ayant des introns ou de LincRNA; la séquence des épissages sites de ces trois classes est similaire (consensus) chez l'homme comme chez la souris car cette similarité est nécéssaire pour la bonne réalisation de l'épissage.  

###### citations
>Ne vend pas la peau de l'ours avant d'avoir les logos  
 _Zacharie_  
