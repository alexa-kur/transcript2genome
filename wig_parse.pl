#!/usr/bin/perl
my $chr="chr1";
if ($ARGV[0] eq '--help'){
    print "USAGE:
./wig_parse.pl WIG_FILE [+|_]\n wig filename  must not contain spaces!!!chromosome names must be as 'chrNUM' and starts from 'chr1'\n";
exit 0}
my $wigfile;
if (-f $ARGV[0]){
open $wigfile, '<', "$ARGV[0]" or die "wig file doesn't exist!"
}

else {
    print "no wigfile given. See '--help' for more details";
    exit
}
$chr = '';
while (<$wigfile>) {
    if (/chrom=(chr\S+)/){
        if ($prev_step > $start){ 
            print "$chr\tsearch\tpeak\t$start\t$prev_step\t0.0000\t$ARGV[1]\t.\ttranscript_id \"peak_${chr}_$start\n";
        }
        $start = 1;
        $chr = $1;
    }
    elsif (/^(\d+)\s+\d+$/){
        $step = $1;
        if ($step == $prev_step+1){}
        elsif ($start !=1){
            print "$chr\tsearch\tpeak\t$start\t$prev_step\t0.0000\t$ARGV[1]\t.\ttranscript_id \"peak_${chr}_$start\n";
            $start = $step}
        else {
            $start = $step}

        $prev_step = $step

        }

    else {}
    }

if ($step == $prev_step){
            print "$chr\tsearch\tpeak\t$start\t$prev_step\t0.0000\t$ARGV[1]\t.\ttranscript_id \"peak_${chr}_$start\n";
}
