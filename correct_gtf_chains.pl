#!/usr/bin/perl
use strict;
use utf8;
use Getopt::Long;


sub usage {print "Usage: ./correct_gtf_chains.pl [-b|--bam] BAM_FILE [-f|--fasta] REFERENCE_GENOME_FASTA_FILE [-g|--gtf] GTF_FILE [-s|--samtools] PATH_TO_SAMTOOLS [-o|--output] OUTPUT_MASK

-b|--bam        BAM file
-g|--gtf        GTF table with information about peaks
-f|--fasta      use this flag if you want to take reference sequences from GTF files. You
                have to specify fasta file where you'll seek sequences 
-o|--output     Output mask. output will include 'mask.gtf' and 'mask.fasta' file (optional)
-s|--samtools   Full path to samtools executable. Default value is 'samtools'

DESCRIPTION
Some programs made for find peaks from BAM  files have one big issue -
They don't give information about direction of reads that create peak.
This information is very important in transcriptome analisys.
This program takes 3 files as input:
BAM file that was inspected by peakfinder
Reference FASTA genome (optional)
GTF table that keeps information about peaks. Usually GTF is standard 
output of peakfinders\n";
return 0
}


sub reverse_read {my @read = reverse (split ('', $_[0]));
    foreach (@read){if    ($_ eq 'A') {$_ = 'T'}
                    elsif ($_ eq 'T') {$_ = 'A'}
                    elsif ($_ eq 'G') {$_ = 'C'}
                    elsif ($_ eq 'C') {$_ = 'G'}
                    else {}
            }
    return join ('',@read)
}


my $help = '';
my $samtools = 'samtools';
my $gtf_file = '';
my $bam_file = '';
my $fasta_file = '';
my $output_mask;


my $result = GetOptions("gtf=s" => \$gtf_file,
                        "output=s" => \$output_mask,
                        "samtools=s" => \$samtools,
                        "help" => \$help,
                        "fasta=s"=> \$fasta_file,
                        "bam=s"=> \$bam_file,
                        );

if ($help){usage;exit 0};

open my $gtf, '<', "$gtf_file" or die "No GTF File!";
my $gtf_output;
#if (-f "${output_mask}.gtf"){die "output GTF file exists! I don't want to overwrite it\n"}

#else {
open $gtf_output, '>', "${output_mask}.gtf";


while (my $line = <$gtf>){if ($line =~/^[^#]/){
    my @string = split ("\t+|\s+",$line) ;print $string[0];
    my %keys = ('+' => 0, '-' =>0);
    foreach (`$samtools view $bam_file $string[0]:$string[3]-$string[4]`){
        split;
        $_[1] == 16 ? $keys{'-'}+=1 : $keys{'+'} +=1;
        $_[1] == 272 ? $keys{'-'}+=1 : $keys{'+'} +=1;
    }
    if ($keys{'-'} >= $keys{'+'}){
        $line =~s/\+/-/
    }
    else {$line =~s/-/\+/}
    print $gtf_output $line
}
}
