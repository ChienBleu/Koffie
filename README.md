# Koffie Compte rendu Analyses bioinformatiques des données à haut débit M2BBSG 2017/2018 

## Zacharie Menetrier and Martin Mestdagh - 02/12/2017



### Contexte
  
D. Puthier et A. Gonzalez travaillent en collaboration avec F. Lopez sur le développement d’un programme permettant de manipuler des fichiers GTF (Gene transfer format). Le format GTF correspond à un fichier tabulé (i.e. dont les colonnes sont séparées par des tabulations) qui contient des informations concernant des éléments génomiques (souvent des gènes, transcripts et leurs exons).
  
### Objectif du workflow Koffie:
  
Son objectif est de comparer les sites de splicing dans 3 classes de transcrits:  
	  Gènes codants ( protein_coding )
	  LincRNA ( LincRNA )
	  Pseudogènes non procéssés ( unprocessed_pseudogene )
  
Le programme permet de nombreuses manipulations des plus basiques (sélections de lignes/colonnes, insertions, déletions, mises à jour de clefs/attributs) jusqu’aux plus avancées (calculs d’enrichissements en régions génomiques, diagrammes de couverture autour/dans des élements génomiques…) pour finir avec des motifs *Weblogo* pour un rendu visuel.
L'étude sera effectué chez l'homme et la souris.


### Réalisation
Le workflow Koffie a été réalisé sur le serveur pedagogix par ligne de commande Linux du TAGC par _Zacharie Ménétrier_ et _Martin Mestdagh_ durant l'unité d'enseignement Analyses bioinformatiques des données à haut débit enseigné par _Denis Puthier_ et _Aitor Gonzalez_ durant l'année scolaire 2017/2018.
  
### A lire avant d'excecuter
Pour pouvoir utiliser Koffie, il faut tout d'abord lancer le fichier *Makefile*.
  Il est constituer des éléments à installer nécéssaire à l'utilisation de Koffie:  
	- environnement gtftk et cpat.
    
Pour lancer le fichier Makefile veuillez copier la ligne de commande suivante:
	  make install
  
Avant de lancer Koffie, il vous faut aussi créér un fichier *personnal_info.py* contenant deux variables:
	  - WDIR: work directory c'est-à-dire votre répertoire de travail et où se trouve les éléments de Koffie. (exemple: WDIR="/data/home/m2_2017_abd_mestdagh/Koffie/")
	  - ENVS_PATH = environment pathway c'est-à-dire votre chemin d'accès à vos environnement créé par le Makefile. (exemple: ENVS_PATH =  "/data/home/m2_2017_abd_mestdagh/miniconda3/envs")
  Pour cela veuillez copier ceci en ligne de commande sous votre terminal dans le dossier *Koffie*:
	  touch personnal_info.py | subl personnal_info.py
  Et ajoutez vos deux variables expliqués ci-dessus, puis enregistrez le fichier personnal_info.py avec CTRL+S enfin fermez ce fichier avec alt+F4. (NB : le fichier personnal_info.py doit-être dans le même dossier que le fichier Snakefile).
  

### Conclusion
  Le but de Koffie étant de comparer les motifs obtenus weblogo des 3 classes, veullez ouvrir les 3 fichiers weblogo...


