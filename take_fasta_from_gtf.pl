#!/usr/bin/perl

use strict;
use utf8;
use Getopt::Long;
use Bio::DB::Sam;
my $bam_file = '';
my $gtf_file = '';
my $output_file = '';
my $samtools = "samtools";
my $genome= '';
my $help = '';

my $result = GetOptions("gtf=s" => \$gtf_file,
                        "out=s" => \$output_file,
                        "sam=s" => \$samtools,
                        "help" => \$help,
                        "ref=s"=> \$genome
                        );

if ($help){print "\n[-g|--gtf] - input GTF file\n[-o|--out] - output FASTA file\n[-r|--ref] Reference genome sequence in FASTA format\n[-h|--help] - print this help\n\n";exit(0)}
open my $gtf, '<', "$gtf_file" or die "GTF File doesn't exist!";



sub reverse_read {my @read = reverse (split ('', $_[0]));
    foreach (@read){if    ($_ eq 'A') {$_ = 'T'}
                    elsif ($_ eq 'T') {$_ = 'A'}
                    elsif ($_ eq 'G') {$_ = 'C'}
                    elsif ($_ eq 'C') {$_ = 'G'}
                    else {}
            }
    return join ('',@read)
}

#variables
##
my $tag;
my $previous_tag;
my ($chr, $start,$end, $chain,$tag);
my %tags;
my $i;
while (my $line = <$gtf>){
    if ($line =~ /^chr/){
        $line =~/^(chr\S{1,2})\s+\S+\s+\S+\s+(\d+)\s+(\d+)\s+\S+\s+([+-]).*transcript_id\s+"([^"]+)";/;

#base parameters
    $chr = $1;
    $start = $2;
    $end = $3;
    $chain = $4;
    $tag = $5;
 #   print "${chr}:${start}-${end}","\n";
    $tags{"$tag"}{'chain'} = $chain if undef ($tags{"$tag"}{'chain'});
    my @string = split ("\n",`samtools faidx $genome ${chr}:${start}-${end}`);shift @string;
   # print "${chr}:${start}-${end}";
    my $seq = join('',@string);print $seq;
    print "RefNum:",$i++,"\n";
    $tags{"$tag"}{'seq'} .= $seq;
 #   print $tags{"$tag"}{'seq'};
    }
}

open my $output, '>', $output_file;
foreach (keys %tags){
    if ($tags{$_}{'chain'} eq '+'){
        print $output '>',$_,"\n",$tags{$_}{'seq'},"\n"
    }
    else {
        print $output '>',$_,"\n",reverse_read($tags{$_}{'seq'}),"\n"
    }
}
