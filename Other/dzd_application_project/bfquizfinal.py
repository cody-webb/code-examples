#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 14 12:05:30 2020

@author: codywebb
"""

import subprocess
import pybedtools
import os
import matplotlib.pyplot as plt
import numpy as np

lst_of_cov = [] # This will be used to make the final table later. 

def aligner(fastq_file):
    #process1 makes mecA.fa an indexable object for bowtie2. process2 takes 
    # the fastq file of choice and runs all of it against the mecA gene and 
    # outputs the result as a sam file named output.sam. process3 then converts 
    # the sam file into a bam file so that the coverage function can use it. 
    
    
    process1 = subprocess.call(["bowtie2-build", "mecA.fa", "mecA"])
    process2 = subprocess.call(["bowtie2",  "--local", "-x", "mecA", "-U", 
                fastq_file, "-S", "output.sam"])
    process3 = subprocess.call(["samtools", "view", "-bS", "output.sam"],
                stdout=open('output.bam','w'))
    
    return None

#aligner('sample_data/sample0.1.fastq')
    
def coverage(threshold, bam_file):
    
    # the genome_coverage tools takes the bam_file inputted and sees how much
    # of the genome is covered.
    
    a = pybedtools.example_bedtool(bam_file)
    b = a.genome_coverage(bg=True)
    
    # This then tells us how much of the genome is covered by more than the 
    # number of reads provided by the threshold. 
    total = 0
    covered = 0
    for line in b:
        total += 1
        if int(line[3]) > threshold:
            covered += 1
    
    # We then take the fraction and add it to the list at the beginning of the
    # script. 
    fraction = round(covered / total, 4) * 100
    number = "{0:.2f}".format(fraction)
    lst_of_cov.append(number)
    return None



def main():
    # List of the sample_data files that I can use a for loop to cycle through.
    lst_of_files = ['sample_data/sample0.1.fastq', 'sample_data/sample0.2.fastq',
                    'sample_data/sample1.1.fastq', 'sample_data/sample1.2.fastq',
                    'sample_data/sample2.1.fastq', 'sample_data/sample2.2.fastq',
                    'sample_data/sample3.1.fastq', 'sample_data/sample3.2.fastq']
    
    # Perform aligner() and coverage() functions on all of the sample files.
    for fl in lst_of_files:
        aligner(fl)
        
        output_file = os.getcwd() + '/output.bam'
        coverage(5, output_file)
    
    print("Fractional Coverage for Each Sample:")
    for i in range(8):
        print(lst_of_files[i][12:21], '\t', lst_of_cov[i], "%")
        
    for i in range(8):
        lst_of_files[i] = lst_of_files[i][18:21]
        lst_of_cov[i] = float(lst_of_cov[i])
    
    y_pos = np.arange(len(lst_of_cov))
    
    plt.bar(y_pos, lst_of_cov, align='center', alpha=0.5)
    plt.xticks(y_pos, lst_of_files)
    plt.ylabel("Fractional Coverage (in %)")
    plt.xlabel("Sample Number")
    
    plt.show()
        

main()
