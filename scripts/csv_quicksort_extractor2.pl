#!/usr/bin/perl
#
# Consolidates several raw benchmark .txt files into ONE wide CSV
# (one row per run, with a Machine_ID column).
#
# Usage:
#   perl csv_quicksort_extractor2.pl Machine_ID=file.txt [Machine_ID=file.txt ...] > master_measurements.csv
#
# Example:

# perl scripts/csv_quicksort_extractor2.pl \
# Mac_M1="data/Ahnafs-MacBook-Air-2.local_2026-10-31/measurements_15:16_25it.txt" \
# Mac_M1="data/Ahnafs-MacBook-Air-2.local_2026-10-31/measurements_15:20_50it.txt" \
# Mac_M1="data/Ahnafs-MacBook-Air-2.local_2026-10-31/measurements_15:24_100it.txt" \
# Mac_M4="data/Muhammads-MacBook-Air.local_2026-10-31/measurements_15:08_25it.txt" \
# Mac_M4="data/Muhammads-MacBook-Air.local_2026-10-31/measurements_15:10_50it.txt" \
# Mac_M4="data/Muhammads-MacBook-Air.local_2026-10-31/measurements_15:14_100it.txt" \
# Linux_Xeon="data/saimaa_2026-10-31/measurements_14:52_25it.txt" \
# Linux_Xeon="data/saimaa_2026-10-31/measurements_14:59_50it.txt" \
# Linux_Xeon="data/saimaa_2026-10-31/measurements_15:06_100it.txt" \
# Windows="data/Konstantinos-Windows.local_2026-10-31/measurements_17:13_25.txt" \
# Windows="data/Konstantinos-Windows.local_2026-10-31/measurements_17:15_50.txt" \
# Windows="data/Konstantinos-Windows.local_2026-10-31/measurements_17:18_100.txt" \
# Mac_M4_Pro="data/Konstantinos-MacBook-Pro.local_2026-10-31/measurements_17:14_25.txt" \
# Mac_M4_Pro="data/Konstantinos-MacBook-Pro.local_2026-10-31/measurements_17:15_25.txt" \
# Mac_M4_Pro="data/Konstantinos-MacBook-Pro.local_2026-10-31/measurements_17:18_25.txt" \
# > data/master_measurements.csv

#
# The same Machine_ID may be given several times (several files for one machine).

use strict;
use warnings;

die "Usage: $0 Machine_ID=file.txt [Machine_ID=file.txt ...]\n" unless @ARGV;

print "Machine_ID,Size,Seq,Par,Libc\n";

my ($rows, $skipped) = (0, 0);

foreach my $arg (@ARGV) {
    my ($machine, $file) = split /=/, $arg, 2;
    die "Bad argument '$arg' (expected Machine_ID=file.txt)\n"
        unless defined $file && length $machine && length $file;

    open(my $fh, '<', $file) or die "Cannot open '$file': $!\n";

    # Reset state for every file so a truncated file cannot leak into the next.
    my ($size, $seq, $par, $libc);
    my $file_rows = 0;

    while (my $line = <$fh>) {
        $line =~ s/\r?\n$//;    # handles Windows (CRLF) line endings too

        if ($line =~ /^Size: ([\d\.]+)$/) {
            # A new run starts: warn if the previous one was incomplete.
            if (defined $size && (defined $seq || defined $par)) {
                warn "WARN: incomplete run (size $size) in $file\n";
                $skipped++;
            }
            ($size, $seq, $par, $libc) = ($1, undef, undef, undef);
            next;
        }
        if ($line =~ /^Sequential quicksort.*: ([\d\.]+) sec\.$/) { $seq  = $1; next; }
        if ($line =~ /^Parallel quicksort.*: ([\d\.]+) sec\.$/)   { $par  = $1; next; }
        if ($line =~ /^Built-in quicksort.*: ([\d\.]+) sec\.$/) {
            $libc = $1;
            if (defined $size && defined $seq && defined $par) {
                print "$machine,$size,$seq,$par,$libc\n";
                $rows++; $file_rows++;
            } else {
                warn "WARN: incomplete run in $file\n";
                $skipped++;
            }
            ($size, $seq, $par, $libc) = (undef, undef, undef, undef);
            next;
        }
    }
    # End of file: a run that never reached its Built-in line is incomplete.
    if (defined $size && (defined $seq || defined $par)) {
        warn "WARN: incomplete run (size $size) at end of $file\n";
        $skipped++;
    }
    close $fh;
    warn "$machine: $file_rows runs from $file\n";
}

warn "Total: $rows runs written, $skipped incomplete runs skipped\n";