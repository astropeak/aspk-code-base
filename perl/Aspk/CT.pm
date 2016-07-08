package Aspk::CT;
use Exporter 'import';
@EXPORT_OK = qw(enterView rmView findView checkoutFile diffFileGui uncheckoutFile);

my $clearcaseBin = 'cleartool';

sub enterView {
    my $view = shift;
    my $rc = exec($clearcaseBin, "setview", $view);
}

sub rmView {
    my $view = shift;
    system($clearcaseBin, "rmview", "-tag", $view);
    $? && die "Can't remove view $view. Exit code $?\n";
}

sub findView {
    my $pattern = "*".join("*",@_)."*";
    my @views = `$clearcaseBin lsview -short $pattern 2>error_msg`;
    return @views;
}

sub checkoutFile {
    my $file = shift;
    my $output = `$clearcaseBin co -nc $file 2>error_msg`;
}

sub uncheckoutFile {
    my $file = shift;
    my $output = `$clearcaseBin unco -rm $file 2>error_msg`;
}

sub diffFileGui {
    my $file = shift;
    my $output = `$clearcaseBin diff -graphical -predecessor $file 2>error_msg`;
}