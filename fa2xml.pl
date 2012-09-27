#!/usr/bin/perl
use utf8;
use XML::Simple;
use Data::Dumper;
$data = {'item'=>[]};
open my $fasta_file,'<', "$ARGV[0]";

$i = 0;
while (<$fasta_file>){chomp;
    if (/^>/){ $i++;
        $$data{'item'}[$i]{'fasta'} .="$_\n";
        /^>([^\[]*)\[/;
        $$data{'item'}[$i]{'sequence_info_text'} = $1;
        $a = 1;
       while ($a >0){ $a = $_ =~ m/(?<=$2)[^\[]*\[([^=]*)=([^\]]*)\]/;
        $$data{'item'}[$i]{"$1"} = $2 if $1 ne '';}
        }
    else {$$data{'item'}[$i]{"sequence"} .= $_;
          $$data{'item'}[$i]{'fasta'} .="$_\n";
        }
}
#print Dumper ($data);
print XMLout($data, 
    NoAttr => 1,
    KeepRoot   => 1,
    XMLDecl    => "<?xml version='1.0'?>",
    )
