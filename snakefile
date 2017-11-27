WDIR = "/data/home/m2_2017_abd_menetrier/Koffie/README.md"

workdir: WDIR

prefix = "file"

INPUT_FILES = [prefix + "_" + str(x) for x in range(10)]

PARAM_1 = [str(x) for x in range(10)]

START_DIR = "start"

VAR1="{file}"

'''
for i in INPUT_FILES:
	print(i)
'''

rule final:
	threads: 1
	input:  expand("bam/" + VAR1 + "_{par}_trim.bam", zip, file=INPUT_FILES, par=PARAM_1)

rule create_files:
	output: START_DIR + "/" + VAR1 + ".txt"
	message: "--- Creating files ---"
	threads: 1
	shell: """
	touch {output}
	sleep 5
	"""

rule trim:
	input: START_DIR + "/" + VAR1 + ".txt"
	output: txt="trim/" + VAR1 + "_{par}_trim.txt"
	message: "--- Trimming reads ---"
	threads: 1
	shell: """
	touch {output.txt}
	echo "trimming with {threads} processors."
	echo "Processing : {wildcards.file}_{wildcards.par}"
	sleep 5
	"""


rule bam:
	input: txt="trim/" + VAR1 + "_{par}_trim.txt"
	output: "bam/" + VAR1 + "_{par}_trim.bam"
	message: "--- Trimming reads ---"
	threads: 4
	run:
		import time
		print("Using :" + str(threads))
		file_handler = open(output[0], "w")
		for i in range(5):
			file_handler.write(str(i))
		time.sleep(20)


