#!/usr/bin/perl
use Getopt::Long;
use utf8;

sub usage();
sub hd($$);

my ($bc_file,$fastq,$help);
my $mismatch_num = 0;
my $out_folder = "split_fastq";
my $result = GetOptions ("bc_file=s" => \$bc_file,
                         "fastq=s" =>   \$fastq,
                         "help" => \$help,
                         "mismatch_num=i" => \$mismatch_num,
                         "out_folder=s" => \$out_folder,
                         );
usage() if $help;
usage() if (scalar @ARGV == 0);

if (-d $out_folder){
    die "output folder exists!"
}
else {mkdir $out_folder};
                            

#trace file with barcodes and create data structure with names and barcodes
open my $barcodes_file ,"<","$bc_file";
@codes = <$barcodes_file>;
chomp(@codes);
%data_hash;
foreach (@codes){my @data_string = split "\t";
    if  (/^[^#]/){
    $data_hash{"$data_string[2]"} = [$data_string[0],$data_string[1],] if $data_string[2] ne '';
    }
}
foreach( keys(%data_hash)){
    open $data_hash{$_}[2],">","$out_folder/$_.fastq" 
}
open my $undefined, ">","$out_folder/undefined.fastq";

#reading fastq file and splitting it into all files
open my $file, "<","$fastq";
while (!eof($file)){
        for (my $i = 0;$i<8;$i++){
            $onerecord[$i] = <$file>;
        }
        my $flag = 0;
        foreach (keys(%data_hash)){
            my $p1 = $data_hash{$_}[0];
            my $p2 = $data_hash{$_}[1];
            my $filename = $data_hash{$_}[2];
            my $str1 = substr($onerecord[5], 0, length($p1));
            my $str2 = substr($onerecord[1],0, length($p2));
            if (hd($str1,$p1) <= $mismatch_num && hd($str2,$p2) <= $mismatch_num){
                do {$flag =1;print $filename @onerecord}
            }
            print $undefined @onerecord if $flag == 0;
        }
}




sub hd  {
    my ($k,$l) = @_;
    my $mismatch_num = 0;
    my $len = length($k);
    for (my $i = 0;$i<$len;$i++){
        ++$mismatch_num if substr($k,$i, 1) ne substr($l,$i,1);
    }
    return $mismatch_num
}
sub usage(){
print<<EOF;
Barcode splitter for fastq files based on barcode matching.
usage: $0 --bc_file FILE --fastq FILE [--help] [--out_folder FOLDER] [--mismatch_num N]

Arguments:

--bc_file FILE  - Barcodes file name (see explanation below)
--fastq FILE    - Fastq file
--mismatch_num  - Number of mismatches allowed in barcode. Default is 0 
--help          - Print help
--out_folder    - Folder that contains splitted fastq files. Must not exist.
                  default value is 'split_fastq'

Example:
$0 --bc_file barcode.txt --fastq data.fastq --mismatch_num 1 --out_folder Newsplit

Barcode file format
-------------------
#This is comment line. It is skipped in parsing
barcode_R2	barcode_R1	library_name
EOF
exit 1;
}


