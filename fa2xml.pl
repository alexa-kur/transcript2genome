#!/usr/bin/perl
use utf8;
use XML::Simple;
use Data::Dumper;
$data = {'dna_sequences'=>{'item'=>[]}};
open my $fasta_file,'<', "$ARGV[0]";
if ($ARGV[0] eq ''){&Usage()};
if ($ARGV[0] eq '-h'){&Usage()};
if ($ARGV[0] eq '--help'){&Usage()};

$i = 0;
while (<$fasta_file>){chomp;
    if (/^>/){ $i++;
        $$data{'dna_sequences'}{'item'}[$i]{'fasta'} .="$_\n";
        /^>([^\[]*)\[/;
        $$data{'dna_sequences'}{'item'}[$i]{'sequence_info_text'} = $1;
        $a = 1;
       while ($a >0){ $a = $_ =~ m/(?<=$2)[^\[]*\[([^=]*)=([^\]]*)\]/;
        $$data{'dna_sequences'}{'item'}[$i]{"$1"} = $2 if $1 ne '';}
        }
    else {$$data{'dna_sequences'}{'item'}[$i]{"sequence"} .= $_;
          $$data{'dna_sequences'}{'item'}[$i]{'fasta'} .="$_\n";
        }
}
#print Dumper ($data);
print XMLout($data, 
    NoAttr => 1,
    KeepRoot   => 1,
    XMLDecl    => "<?xml version='1.0'?>",
    );
sub Usage {
    print "USAGE:\n";
    print "THIS_SCRIPT.pl FASTA_FILE.fa > XML_FILE.xml\n";
    exit 0;
    return 0;
};
