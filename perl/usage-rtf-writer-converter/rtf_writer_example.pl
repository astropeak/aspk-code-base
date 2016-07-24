use utf8;
use RTF::Writer;
my $rtf = RTF::Writer->new_to_file("greetings.rtf");
$rtf->prolog( 'title' => "omt_sw_readme", 'fonts'=>["Arial"]);
$rtf->number_pages;
# $rtf->paragraph(
#   \'\fs40\b\i',  # 20pt, bold, italic
#   "Hi there!"
# );
# $rtf->close;



my $h1 = '\fs30\b';
my $h2 = '\fs20\b';
my $h3 = '\fs18\b';
my $h4 = '\fs18 \li500';
my $h5 = '\fs16 \li800';
my $h6 = '\fs16 \li1000';

# open my $fh, "<:encoding(UTF-8)", "omt_sw_readme.txt" or die "Can't open file";
open my $fh, "<", "omt_sw_readme.txt" or die "Can't open file";
while (<$fh>){
    if (/^\d+\s+(.*)/) {
        # $rtf->paragraph(\$h1, $_);
        $rtf->print(
            \'{\fs30{\* \pn\pnlvl1\pndec}{\ltrch');
 $rtf->print($1);
$rtf->print(\'}\li120\ri0\sa0\sb0\jclisttab\tx720\fi-360\ql\par}');


            } elsif (/^\d+\.\d+\s+(.*)/){
                # $rtf->paragraph(\$h2, $_);
                $rtf->print(

                    \'{\fs20{\* \pn\pnlvl2\pndec\pnprev}{\ltrch');
                       $rtf->print($1);
                       $rtf->print(\'}\li320\ri0\sa0\sb0\jclisttab\tx720\fi-360\ql\par}');


                    } elsif (/^\d+\.\d+\.\d+\s+(.*)/){
                        # $rtf->paragraph(\$h3, $_);

                        $rtf->print(
                            \'{\fs18{\* \pn\pnlvl3\pnprev\pndec\pnstart1}{\ltrch');
                $rtf->print($1);
                $rtf->print(\'}\li520\ri0\sa0\sb0\jclisttab\tx720\fi-360\ql\par}');


                            } elsif (/^\x{b7}\s+(.*)/) {
                                # $rtf->print(\'{\listtext\pard\plain\ltrpar \s25 \rtlch\fcs1 \af1\afs22 \ltrch\fcs0 \f3\fs22\lang1033\langfe1033\langfenp1033\insrsid14748805 \loch\af3\dbch\af13\hich\f3 \'b7\tab}');
        # $rtf->print(\'\levelnfc23');

        $rtf->print(
            \'{\fs18{\pntext \\\'B7\tab}{\*\pn\pnlvlblt\pnstart1{\pntxtb\\\'B7}}{\ltrch');
 $rtf->print($1);
$rtf->print(\'}\li720\ri0\sa0\sb0\jclisttab\tx720\fi-360\ql\par}');

               # $rtf->print(\'\levelnfc23');
               # $rtf->paragraph(\$h4, $1);
            } elsif (/^o\s+(.*)/) {
                $rtf->paragraph(\$h5, $_);
            } else {
                $rtf->paragraph(\$h6, $_);
            }
            }

        $rtf->close;