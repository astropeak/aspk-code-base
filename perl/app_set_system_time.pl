#!/usr/bin/perl
# DONE: collect to pcs
# Set system time. Can only run under linux. Depended linux command: sudo, w3m, date.

open my $fh, "w3m http://www.timeanddate.com/worldclock/china/chengdu -dump|" || die "Can't w3m";
local $/;
<$fh> =~ m/Home > Time Zones >(?:.*\n){3,8}([\d:]+)(?:.*\n){2}(.*)/;
# $cmd = "sudo date -s $1 $2";
# print "Executing: $cmd\n";
system("sudo","date","-s",$1." ".$2);
