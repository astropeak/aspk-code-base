package Aspk::Misc;
use Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(module_full_path);

# get a module's full path given module name
# If not found, return empty string
sub module_full_path {
    my $module=shift;
    my $file = join "/", split "::", $module;
    foreach (@INC){
        my $t="$_/$file.pm";
        if (-e $t) {
            return $t;
        }
    }
    return "";
}

