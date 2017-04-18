#!/usr/bin/perl
#DONEpcs
# usage: app_process_each_line.pl COMMAND. COMMAND is valid perl statements. $_ is bound to the current line string.

my $cmd=$ARGV[0];
my $func = eval "sub{while(<STDIN>){chomp;$cmd;}}";
die "unable to compile '$cmd', aborting...\n" if not defined $func;
$func->();

