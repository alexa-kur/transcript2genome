#!/usr/bin/perl
open my $wigfile, '<', "$ARGV[0]";
my $chr="chr1";

while (<$wigfile>) {
    if (/chrom=(chr\S+)/){
        if ($prev_step > $start){
            print "$chr\tsearch\tpeak\t$start\t$prev_step\t0.0000\t$ARGV[1]\t.\ttranscript_id \"peak_${chr}_$start\n";
        $chr = $1;
        }
        $start = 1;
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


