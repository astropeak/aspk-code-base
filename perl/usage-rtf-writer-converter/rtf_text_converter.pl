use strict;        use RTF::TEXT::Converter;

my $object = RTF::TEXT::Converter->new(

    output => \*STDOUT

    );

open RTF_FILE, "<", "omt_sw_readme.rtf" or die "Can't open file";
$object->parse_stream( \*RTF_FILE );