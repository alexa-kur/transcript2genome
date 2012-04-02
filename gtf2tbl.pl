#!/usr/bin/perl
$feature = '';
while (<>){next if /^#/;
    $i++;
    chomp;
    @a = split (/\t/, $_); 
    print ">Feature\t$a[0]\n" if $a[0] ne $feature; 
    $feature = $a[0];
    
    if ($a[6] eq "+") {
        print "$a[3]\t$a[4]\tgene\n";
        }
    else {print "$a[4]\t$a[3]\tgene\n";
    }

    $a[8] =~/Name=(.*)/;$name = $1;
    if ($name=~/(.+):hypothetical/){
        print "\t\t\tgene\t$name\n"
    }
    print"\t\t\tlocus_tag\tMV1_";
    printf "%04d\n", $i;
    if ($a[6] eq "+") {
        print "$a[3]\t$a[4]\tprotein\n";
        }
    else {print "$a[4]\t$a[3]\t$a[2]\n";
    }
    print "\t\t\tprotein_id\tbcc|icbfm|MV1_";
    printf "%04d\n", $i;
    $a[8] =~ /Name=(.+)/; $name = $1;
    print "\t\t\tproduct\t$name\n";
    

}
