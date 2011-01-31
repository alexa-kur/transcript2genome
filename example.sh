#!/bin/sh
./main_current.pl -g YOUR_GTF.gtf -b YOR_TRANSCRIPT_BAM.bam > OUTPUT.sam
samtools view -bS OUTPUT.sam > OUTPUT.bam
samtools sort OUTPUT.bam OUTPUT_SORTED
samtools index OUTPUT_SORTED.bam
rm OUTPUT.sam OUTPUT.bam
