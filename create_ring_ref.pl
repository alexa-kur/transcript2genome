#!/usr/bin/perl

use strict;
use utf8;
use Getopt::Long;
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

if ($help){print "\n[-g|--gtf] - input GTF file\n[-o|--out] - output FASTA file\n[-r|--ref] Reference genome sequence in FASTA format\n[-h|--help] - print this help\n[-s|--sam] samtools binary you use\n\n";exit(0)}
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
    if ($line =~ /^[^#]/){
        $line =~/^(\S+)\s+\S+\s+exon\s+(\d+)\s+(\d+)\s+\S+\s+([+-]).*transcript_id\s+"([^"]+)";/;

#base parameters
    	$chr = $1;
    	$start = $2;
    	$end = $3;
    	$chain = $4;
    	#$tag = $start."-".$end.".".$chain;
    	$tag = $5;
    	
    	$tags{"$tag"}{'chain'} = $chain if $tags{"$tag"}{'chain'} eq '';
    	my $j = 1;
    	my $exon_exists = 1;
    	while ($exon_exists){
    	    if ($tags{"$tag"}{$j} =~/[AGTCagtc]/){$j++;
    	        next}
    	    else {$exon_exists = 0;
    	    my @string = split ("\n",`$samtools faidx $genome ${chr}:${start}-${end}`);shift @string;
    	    $tags{"$tag"}{$j} = join('',@string);
    	    }
    	}
    }
}

#write output
my @transcript_ids = keys %tags;

open my $output, ">","$output_file";
foreach my $id (@transcript_ids){
    my $exon_number = scalar(keys %{$tags{$id}}) - 1;
    

    if ($tags{$id}{'chain'} eq '+'){
        for (my $i =$exon_number ; $i > 0;$i--){
            my $start = substr $tags{$id}{$i}, -30;
            for (my $j = $i -1; $j>0;$j--){
                my $end = substr $tags{$id}{$j},0,30;
                print $output ">$id"."_exon"."$i"."_exon"."$j\n";
                print $output $start.$end."\n";
            }
        }
    }
    elsif ($tags{$id}{'chain'} eq '-'){
        for (my $i =1 ; $i < $exon_number;$i++){
            my $start = reverse_read(substr $tags{$id}{$i}, 0,30);
            my $number_start = $exon_number -$i+1;
            for (my $j = $i+1;$j<$exon_number;$j++){
                my $end =reverse_read(substr $tags{$id}{$j},-30);
                my $number_end = $exon_number - $j + 1;
                print $output ">$id"."_exon"."$number_start"."_exon"."$number_end\n";
                print $output $start.$end."\n";
            }
        }
    }
    else {}
}



