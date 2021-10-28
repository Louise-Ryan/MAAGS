#!/usr/bin/env python3

#conda activate py39 --> to run this script, as biopython is loaded here

from Bio import SeqIO

for seq_record in SeqIO.parse("AllMammalReceptors_excluding_OR_psuedogenes.fa", "fasta"):
    length_seq = len(seq_record)
    if length_seq < 200: 
        print(seq_record.id)
        print(len(seq_record))
