zcat /projectnb/bf528/project_4_scrnaseq/fastq/SRR3879604/SRR3879604_1_bc.fastq.gz | awk '{if (NR%4==2){print substr($1,1,19)}' | sort | uniq -c | awk '{if ($1 > 80000){print $2}}' > barcodes_awk1.txt

zcat /projectnb/bf528/project_4_scrnaseq/fastq/SRR3879604/SRR3879604_1_bc.fastq.gz | awk '{if (NR%4==2){print substr($1,1,19)}' | sort | uniq -c | awk '{if ($1 > 80000){print $2}}' > barcodes_awk2.txt

zcat /projectnb/bf528/project_4_scrnaseq/fastq/SRR3879604/SRR3879604_1_bc.fastq.gz | awk '{if (NR%4==2){print substr($1,1,19)}' | sort | uniq -c | awk '{if ($1 > 80000){print $2}}' > barcodes_awk3.txt
