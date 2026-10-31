#!/usr/bin/perl
#
# Consolidates several raw benchmark .txt files into ONE wide CSV
# (one row per run, with a Machine_ID column).
#
# Usage:
#   perl csv_quicksort_extractor2.pl Machine_ID=file.txt [Machine_ID=file.txt ...] > master_measurements.csv
#
# Example:
#   perl scripts/csv_quicksort_extractor2.pl \
#       Mac_M1="data/host1_2026-11-02/measurements_10:15_30it.txt" \
#       Mac_Intel="data/host2_2026-11-02/measurements_10:20_30it.txt" \
#       Windows_WSL="data/host3_2026-11-02/measurements_10:30_30it.txt" \
#       Linux="data/host4_2026-11-02/measurements_10:40_30it.txt" \
#       > data/master_measurements.csv
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