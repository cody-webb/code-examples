zcat /projectnb/bf528/project_4_scrnaseq/fastq/SRR3879604/SRR3879604_1_bc.fastq.gz | awk '{if (NR%4==2){print substr($1,1,19) "\t" substr($1,20,6)}' | cut -f 1 | sort | uniq -c | awk '{print $1}' | sort | uniq -c > bc_counts_awk1.txt 

zcat /projectnb/bf528/project_4_scrnaseq/fastq/SRR3879605/SRR3879605_1_bc.fastq.gz | awk '{if (NR%4==2){print substr($1,1,19) "\t" substr($1,20,6)}'| cut -f 1 | sort | uniq -c | awk '{print $1}' | sort | uniq -c > bc_counts_awk2.txt 

zcat /projectnb/bf528/project_4_scrnaseq/fastq/SRR3879606/SRR3879606_1_bc.fastq.gz | awk '{if (NR%4==2){print substr($1,1,19) "\t" substr($1,20,6)}'| cut -f 1 | sort | uniq -c | awk '{print $1}' | sort | uniq -c > bc_counts_awk3.txt 
