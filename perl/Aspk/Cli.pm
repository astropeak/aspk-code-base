package Aspk::Cli;
use Exporter 'import';
@EXPORT_OK = qw(make_choice prompt_get current_user);

sub make_choice {
    my $arg = shift;
    my @list = @{$arg->{"list"}};
    if ($#list == -1) {
        return "";
    }

    my $header = $arg->{"header"} || "All choices:";
    chomp $header;
    print "$header\n";
    foreach my $i (0 .. $#list) {
        my $j = $i+1;
        chomp $list[$i];
        print "  [$j] $list[$i]\n";
    }

    if ($#list == 0) {
        return $list[0];
    } else {
        my $choice;
        do {
            print "Select (Enter a number between 1 and ${\scalar(@list)}): ";
            $choice = <STDIN>;
        } while (!($choice >= 1 && $choice <= (scalar @list)));
        return $list[$choice-1];
    }
}

sub prompt_get {
    my $arg = shift;
    my $prompt = $arg->{"prompt"} || "Input";
    my $check = $arg->{"check"} || sub {return 1;};
    my $type = $arg->{"type"};
    my $numMin = $arg->{"numMin"} || -9999999;
    my $numMax = $arg->{"numMax"} ||  9999999;
    if ($type eq "number") {
        if (!$arg->{"check"}) {
            $check = sub {
                my $a = shift;
                return ($a >= $numMin && $a<=$numMax);
            };
        }
    }

    my $default = $arg->{"default"};

    chomp $prompt;
    my $input;
    do {
        if (defined $default) {print "$prompt [$default]: ";}
        else {print "$prompt: ";}
        $input = <STDIN>;
        chomp $input;
        # print "\ninput: $input\n\n";
    } while(!(($input =~ m/^\s*$/)?(defined $default):$check->($input)));
    # } while(!($check->($input) || ($default && $input =~ m/^\s*$/)));

    if ($input !~ m/^\s*$/) {return $input;}
    # if (!($input =~ m/^\s*$/)) {return $input;}
    else {return $default;}
}


sub current_user {
   return $ENV{LOGNAME} || $ENV{USER} || getlogin || getpwuid($<);
}

return 1;