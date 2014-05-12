#!/usr/bin/env perl

use strict;
use warnings;

use constant OPENLEARNING_MAGICAL_PREFIX => 'https://www.openlearning.com/courses/99luftballons/Cohorts/ClassOf2014/Groups/Tutors/MagicalMarkingPages';

if (int(@ARGV) != 1) {
    printf("Usage: $0 <report-directory>\n");
    exit(-1);
}

my $reportsDirectory = $ARGV[0];

my $tableHtml = "<table class='table table-bordered'>\n";

$tableHtml .= "    <tr>\n";
$tableHtml .= "        <th>Group name</th>\n";
$tableHtml .= "        <th>Average progress</th>\n";
$tableHtml .= "    </tr>\n";

my $numGroups = 0;
my $totalProgress = 0;

opendir(my $reportsFh, $reportsDirectory) or die $!;

my @reportFiles = sort { $a cmp $b } readdir($reportsFh);

while (my $filename = shift @reportFiles ) {

    next if ($filename =~ /^\./);
    next if ($filename =~ /index\.html/);

    my $reportFilename = sprintf("%s/%s", $reportsDirectory, $filename);
    my $groupName = $filename;
    $groupName =~ s/\.html//;

    my $groupLink = sprintf("%s/%s", OPENLEARNING_MAGICAL_PREFIX, $groupName);
    my $prettyGroupLink = sprintf("<a href='%s'>%s</a>\n", $groupLink, $groupName);

    my $progress;

    # find progress in the file

    open (my $reportFile, '< ' . $reportFilename) or die $!;
    foreach my $line (<$reportFile>) {
        chomp $line;
        if ($line =~ /<p>Average student progress: (.*)%<\/p>/) {
            $progress = 0.0 + $1;
        }
    }
    close ($reportFile);

    die "Missing progress in $reportFilename" if !defined($progress);

    my $backgroundColour; 
    if ($progress >= 70) {
        $backgroundColour = "#CCFFCC";
    } elsif ($progress >= 50) {
        $backgroundColour = "#FFE5CC";
    } else {
        $backgroundColour = "#FFAAAA";
    }

    $tableHtml .= "    <tr>\n";
    $tableHtml .= "        <td style='background-color: $backgroundColour'>$prettyGroupLink</td>\n";
    $tableHtml .= sprintf("        <td style='background-color: %s'>%3.1f%%</td>\n", $backgroundColour, $progress);
    $tableHtml .= "    </tr>\n";

    $totalProgress += $progress;
    $numGroups += 1;
}

closedir($reportsFh);

$tableHtml .= "</table>\n";

my $averageProgress = (1.0 * $totalProgress) / $numGroups;

printf ("%s", $tableHtml);

printf("<p>Average group progress: %3.1f%%</p>\n", $averageProgress);

printf("<p>GitHub: <a href='https://github.com/optimuscoprime/ol-group-marking'>https://github.com/optimuscoprime/ol-group-marking</a></p>\n");
