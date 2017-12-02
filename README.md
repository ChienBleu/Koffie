# Workflow de comparaison des sites de splicing pour 3 classes de transcrits (LincRNA, protéines codantes et pseudogènes non procéssés) chez l'homme et chez la souris 

#### Compte rendu Analyses bioinformatiques des données à haut débit M2BBSG 2017/2018 Denis Puthier et Aitor Gonzalez

## Zacharie Menetrier and Martin Mestdagh - 02/12/2017



### Contexte
  
D. Puthier et A. Gonzalez travaillent en collaboration avec F. Lopez sur le développement d’un programme permettant de manipuler des fichiers GTF (Gene transfer format). Le format GTF correspond à un fichier tabulé (i.e. dont les colonnes sont séparées par des tabulations) qui contient des informations concernant des éléments génomiques (souvent des gènes, transcripts et leurs exons).
  
### Objectif du workflow:
  
Son objectif est de comparer les sites de splicing dans 3 classes de transcrits:  
	  Gènes codants ( protein_coding )  
	  LincRNA ( LincRNA )  
	  Pseudogènes non procéssés ( unprocessed_pseudogene )  
  
Le programme permet de nombreuses manipulations des plus basiques (sélections de lignes/colonnes, insertions, déletions, mises à jour de clefs/attributs) jusqu’aux plus avancées (calculs d’enrichissements en régions génomiques, diagrammes de couverture autour/dans des élements génomiques…) pour finir avec des motifs **Weblogo** pour un rendu visuel.  
L'étude sera effectué chez l'homme (hg39 release 90)  et la souris (mm10 release 90).  


### Réalisation
Le workflow a été réalisé sur le serveur pedagogix du TAGC par ligne de commande.  
Il s'agit d'un compte rendu de l'unité d'enseignement Analyses bioinformatiques des données à haut débit (ABD) enseigné par _Denis Puthier_ et _Aitor Gonzalez_ durant l'année scolaire 2017/2018.  
  
### A lire avant d'exécuter
Pour pouvoir utiliser le workflow, il faut tout d'abord lancer le fichier *Makefile*.
  Il est constituer des éléments à installer nécéssaire à l'utilisation de Koffie:  
	- installation de conda.  
	- environnement gtftk et cpat.  
    
Pour lancer le fichier Makefile veuillez copier la ligne de commande suivante:  
	  make install  
  
Avant de lancer le workflow, il vous faut créér un fichier *personal_info.py* contenant deux variables:  
	  - WDIR: work directory c'est-à-dire votre répertoire de travail et où se trouve les éléments de du workflow. (exemple: WDIR="/data/home/m2_2017_abd_mestdagh/Koffie/")  
	  - ENVS_PATH = environment pathway c'est-à-dire votre chemin d'accès à vos environnement créé par le Makefile. (exemple: ENVS_PATH =  "/data/home/m2_2017_abd_mestdagh/miniconda3/envs")  
  Pour cela veuillez copier ceci en ligne de commande sous votre terminal dans le dossier **Koffie**:  
	  touch personnal_info.py | subl personnal_info.py  

Ajoutez vos deux variables expliqués ci-dessus, puis enregistrez le fichier personnal_info.py avec CTRL+S enfin fermez ce fichier avec alt+F4. (NB : le fichier personal_info.py doit-être dans le même dossier que le fichier Snakefile).
  

### Conclusion
#### Comparaison des weblogo de l'humain
#### Comparaison des weblogo de la souris


