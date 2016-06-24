use Text::Template;

my $template = Text::Template->new(SOURCE => 'letter.tmpl')
    or die "Couldn't construct template: $Text::Template::ERROR";

my @monthname = qw(January February March April May June
                           July August September October November December);
my %vars = (title => 'Mr.',
            firstname => 'Bill',
            lastname => 'Gates',
            last_paid_month => 1,   # February
            amount => 392.12,
            monthname => \@monthname,
    );

my $result = $template->fill_in(HASH => \%vars);

if (defined $result) { print $result }
else { die "Couldn't fill in template: $Text::Template::ERROR" }