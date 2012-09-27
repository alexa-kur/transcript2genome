#!/usr/bin/perl
use utf8;
use XML::Simple;
use Data::Dumper;
if ($ARGV[0] eq ''){print "USAGE: THIS_SCRIPT.pl XML_FILE.xml > FASTA_FILE.fa\n";exit 0}
if ($ARGV[0] eq '--help'){print "USAGE: THIS_SCRIPT.pl XML_FILE.xml > FASTA_FILE.fa\n";exit 0}
if ($ARGV[0] eq '-h'){print "USAGE: THIS_SCRIPT.pl XML_FILE.xml > FASTA_FILE.fa\n";exit 0}

my $file = XMLin ("$ARGV[0]");
print Dumper ($file);
foreach (@{$$file{'item'}}) {
#    print $$_{'fasta'}
    }
