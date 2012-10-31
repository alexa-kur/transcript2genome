#!/usr/bin/perl
open my $fastq, "<", "$ARGV[0]" or die "no file! give fasta file in ARGV\n";
my $filename = $ARGV[0];
my $csfasta_filename = $filename.".csfasta";
my $qual_name = $filename."_QV.qual";
open my $csfasta, ">", "$csfasta_filename";
open my $qual, ">","$qual_name";

while (1){
    &print_one_read($fastq);
    last if eof ($fastq)
}

sub print_one_read { my $fastq = $_[0];
    $name = <$fastq>;
    chomp $name;
    $name =~ s/@/>/;
    $read = <$fastq>;
    print $csfasta $name, "\n", $read;

    my $qualname = <$fastq>;
    $qual_string = <$fastq>;
    chomp $qual_string;
    @quals = split "", $qual_string;
    print $qual $name,"\n";
    foreach (@quals){
        #my $current_qual = log (1 + 10 ** ((ord ($_) - 64) / 10)) / log (10);
        my $value = ord ($_)-33; $value-- if $value ==0;
        printf $qual "%1.0f ", $value;
    }
    print $qual "\n";
}

