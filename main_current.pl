#!/usr/bin/perl
use strict;
use utf8;
use Getopt::Long;
use Bio::DB::Sam;
my $bam_file = '';
my $gtf_file = '';
my $output_file = '';
my $samtools = "samtools";
my $help = '';

my $result = GetOptions("bam=s" => \$bam_file,
                        "gtf=s" => \$gtf_file,
                        "out=s" => \$output_file,
                        "sam=s" => \$samtools,
                        "help" => \$help
                        );

if ($help){print "[-b|--bam] - input BAM file\n[-g|--gtf] - input GTF file\n[-o|--out] - output BAM file\n[-h|--help] - print this help\n\n";
    die"Bye Bye";}

#opening all files
open my $gtf, '<', "$gtf_file" or die "GTF File doesn't exist!";
my $inbam = Bio::DB::Sam->new (-bam => "$bam_file");

sub reverse_read {my @read = reverse (split ('', $_[0]));
    foreach (@read){if    ($_ eq 'A') {$_ = 'T'}
                    elsif ($_ eq 'T') {$_ = 'A'}
                    elsif ($_ eq 'G') {$_ = 'C'}
                    elsif ($_ eq 'C') {$_ = 'G'}
                    else {}
            }
    return join ('',@read)
}

#variables in cycle
my $sum_length = 0;
my $code;
my $chr;
my $start;
my $end;
my $sum_length;
my $local_start;
my $local_end;
my $iterator;
my $bam_line;
my $tam_line;
my $chain;
my @plus_lines;
my @minus_lines;
my $i;
my $previous_start = 0;
my $previous_end = 0;

#Print header to the SAM file
print	'@HD	VN:1.0	SO:coordinate
@SQ	SN:chr10	LN:135534747
@SQ	SN:chr11	LN:135006516
@SQ	SN:chr12	LN:133851895
@SQ	SN:chr13	LN:115169878
@SQ	SN:chr14	LN:107349540
@SQ	SN:chr15	LN:102531392
@SQ	SN:chr16	LN:90354753
@SQ	SN:chr17	LN:81195210
@SQ	SN:chr18	LN:78077248
@SQ	SN:chr19	LN:59128983
@SQ	SN:chr1	LN:249250621
@SQ	SN:chr20	LN:63025520
@SQ	SN:chr21	LN:48129895
@SQ	SN:chr22	LN:51304566
@SQ	SN:chr2	LN:243199373
@SQ	SN:chr3	LN:198022430
@SQ	SN:chr4	LN:191154276
@SQ	SN:chr5	LN:180915260
@SQ	SN:chr6	LN:171115067
@SQ	SN:chr7	LN:159138663
@SQ	SN:chr8	LN:146364022
@SQ	SN:chr9	LN:141213431
@SQ	SN:chrM	LN:16571
@SQ	SN:chrX	LN:155270560
@SQ	SN:chrY	LN:59373566
';
while (my $line = <$gtf>){if ($i =~ /^chr\S+\s+\S+\s+exon.*\+/){push (@plus_lines, $line)}
                 elsif ($i =~ /^chr\S+\s+\S+\s+exon.*\-/){unshift (@minus_lines, $line)}
                 else {}
}

foreach my $line (@plus_lines){
        $line =~/^(chr\S{1,2})\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S)\t(\S)\t(\S+)\s\"(\S+)\";\s\S+\s\"(\S+)\";$/;
        #chr = $1; 
        #source = $2; 
        #type = $3; 
        #start = $4; 
        #end = $5;
        #chain = $7;
        #CDS = $8;
        #gene = $10;
        #code = $11;

        #base parameters
        $chr = $1;
        $start = $4;
        $end = $5;
        $chain = $7;

        #if not first exon
        if ($code eq $11){       #local alignment parameters
            $local_start = $sum_length + 1;
            $sum_length = $end - $start + $sum_length + 1;
            $local_end = $sum_length;
        }
        
        else {
            $code = $11;     #if the first exon
            $sum_length = $end - $start + 1;
            $local_start = 1;
            $local_end = $sum_length;
        }

            #iterator per BAM file
            $iterator = $inbam->features(-seq_id => $code, 
                                           -start => $local_start,
                                           -end => $local_end,
                                           -iterator => 1);
            while ($bam_line = $iterator->next_seq) {
                
                #base functional
                my ($qname,
                    $flag, 
                    $rname, 
                    $pos, 
                    $mapq,
                    $cigar,
                    $mrnm,
                    $mpos,
                    $isize,
                    $seq,
                    $qual,
                    @tags) = split "\t", $bam_line->tam_line;
                
                my $position = $pos - $local_start + $start;
                my $read_length = length ($seq);
                
                
                if ($position + $read_length < $end && $position > $start) {
                    print join "\t", ($qname,$flag,$chr,$position,$mapq,$cigar,$mrnm,$mpos,$isize,$seq,$qual,@tags);
                    print "\n";
                    }
                
                elsif ($position + $read_length < $end && $position < $start) {
                    $position = $previous_end - $local_start + $pos + 1;

                    my $insert = $start - $previous_end;
                    my $before_ins = $previous_end - $position + 1;
                    my $after_ins = $read_length - $before_ins;
                    $cigar = $before_ins."M".$insert."N".$after_ins."M";
                    print join "\t", ($qname,$flag,$chr,$position,$mapq,$cigar,$mrnm,$mpos,$isize,$seq,$qual,@tags);
                    print "\n";
                    }
                else {}


          } 

                $previous_end = $end;  #this is callback to save previous end position
                
            }


#print @minus_lines;
foreach my $line (@minus_lines){

        $line =~/^(chr\S{1,2})\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S)\t(\S)\t(\S+)\s\"(\S+)\";\s\S+\s\"(\S+)\";$/;
        #base parameters
        $chr = $1;
        $start = $4;
        $end = $5;
        $chain = $7;

        if ($code eq $11) {

            $local_start = $sum_length + 1;
            $sum_length = $end - $start + $sum_length + 1;
            $local_end = $sum_length;
        }
        #if the first exon
        else {
            $code = $11;
            $sum_length = $end - $start + 1;
            $local_start = 1;
            $local_end = $sum_length;
        }

            #iterator per BAM file
            $iterator = $inbam->features(-seq_id => $code, 
                                           -start => $local_start,
                                           -end => $local_end,
                                           -iterator => 1);

            while ($bam_line = $iterator->next_seq) {
                
                my ($qname,
                    $flag, 
                    $rname, 
                    $pos, 
                    $mapq,
                    $cigar,
                    $mrnm,
                    $mpos,
                    $isize,
                    $seq,
                    $qual,
                    @tags) = split "\t", $bam_line->tam_line;
                #base functional

                my $rev_seq = reverse_read($seq);
                my $rev_qual = join('',reverse(split('',$qual)));

                my $read_length = length ($seq);
                my $position = $end - $pos + $local_start - $read_length + 1;
                
                
                if ($position + $read_length < $end && $position > $start) {
                    print join "\t", ($qname,$flag,$chr,$position,$mapq,$cigar,$mrnm,$mpos,$isize,$rev_seq,$rev_qual,@tags);
                    print "\n";
                    }
                
                elsif ($position + $read_length > $end && $position > $start) {
                    $position = $previous_start - $local_end + $pos + 1;

                    my $insert = $previous_start - $end;
                   # my $before_ins = $previous_start - $position + 1;
                   my $before_ins = $end - $local_start + $pos;
                   # my $after_ins = $read_length - $before_ins;
                   my $after_ins = $previous_start + $pos;



                    $cigar = $before_ins."M".$insert."N".$after_ins."M";
                    print join "\t", ($qname,$flag,$chr,$position,$mapq,$cigar,$mrnm,$mpos,$isize,$seq,$qual,@tags);
                    print "\n";
                    }
                else {}
                #print "$1 $pos $end $read_length $tam_line\n";

        }
        $previous_start = $start;#callback to create correct junctions
}



#остались только проблемы с джанками


#если цепь прямая, и флаг правильный, 0, то ничего делать не надо.
    #Если цепь обратная, то надо развернуть и перебра
