#!/usr/bin/perl
if ($ARGV[0] eq ''){print "Usage: cat file.gtf | THIS_SCRIPT.pl > new.gtf\nAlso see README"};
while (my $line = <>){ 
    $line =~s/\"(N._\d*_)dup11\"/\"\1dup12\"/g; 
    $line =~s/\"(N._\d*_)dup10\"/\"\1dup11\"/g; 
    $line =~s/\"(N._\d*_)dup9\"/\"\1dup10\"/g; 
    $line =~s/\"(N._\d*_)dup8\"/\"\1dup9\"/g; 
    $line =~s/\"(N._\d*_)dup7\"/\"\1dup8\"/g; 
    $line =~s/\"(N._\d*_)dup6\"/\"\1dup7\"/g; 
    $line =~s/\"(N._\d*_)dup5\"/\"\1dup6\"/g; 
    $line =~s/\"(N._\d*_)dup4\"/\"\1dup5\"/g; 
    $line =~s/\"(N._\d*_)dup3\"/\"\1dup4\"/g; 
    $line =~s/\"(N._\d*_)dup2\"/\"\1dup3\"/g; 
    $line =~s/\"(N._\d*_)dup1\"/\"\1dup2\"/g; 

      $line =~s/("N._[0-9.]*)"/\1_dup1"/g;
    print $line;
    }
