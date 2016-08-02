#!/usr/bin/env perl

use strict;
use warnings;

my @default_chrom_ids = ();
my %CHROM_ID_VAR_MAP = ();

## read <DATA> containing all chromosome Id variations
## possible chromosome Ids are converted to lowercase strings
## store mapping between possible and expected chromosome Ids
## e.g. "chr01" resolves to "Chr1" (expected)
while(<DATA>) {
    chomp;
    my @line = split " ";
    push @default_chrom_ids, $line[0];
    for(my $i = 0; $i < scalar @line; $i++) {
        $CHROM_ID_VAR_MAP{lc $line[$i]} = $line[0];
    }
}
close DATA;

## iterate through input file (passed by name or via stdin)
## if line starts with '#', print as-is
## else, split line at '\t', verify and fix chrom ID in first column
while(<>) {
    chomp;
    if(/^#/) { print "$_\n"; }
    else {
        my @line = split /\t/;
        my $k = lc $line[0];
        if(defined $CHROM_ID_VAR_MAP{$k}) {
            $line[0] = $CHROM_ID_VAR_MAP{$k};
        }
        print join ("\t", @line) . "\n";
    }
}

exit;

__DATA__
Chr1 Chr01 1 CP002684.1 NC_003070.9 AtChr1
Chr2 Chr02 2 CP002685.1 NC_003071.7 AtChr2
Chr3 Chr03 3 CP002686.1 NC_003074.8 AtChr3
Chr4 Chr04 4 CP002687.1 NC_003075.7 AtChr4
Chr5 Chr05 5 CP002688.1 NC_003076.8 AtChr5
ChrC ChrCp C AP000423.1 NC_000932.1 Cp Pt
ChrM ChrMt M Y08501.2 NC_001284.2 Mt
