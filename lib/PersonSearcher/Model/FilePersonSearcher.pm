package PersonSearcher::Model::FilePersonSearcher;

use strict;
use warnings;
use utf8;
use open OUT => qw/:utf8 :std/;
use English;
use FindBin;
use Text::CSV;
use Exporter 'import';
our @EXPORT_OK = qw{get_name_for_file};

# use Smart::Comments;

use IO::File;
sub get_name_for_file {
    my $cond = shift;

    my $res = +{
        last_names  => [],
        first_names => [],
    };

    my $file_path
        = $FindBin::Bin . '/../../lib/PersonSearcher/Model/ime-import.txt';

    my $csv = Text::CSV->new(+{
        binary   => 1,
        sep_char => "\t",
    });

    open my $ime_file, '<:encoding(utf8)', $file_path
        or die "no file $OS_ERROR";

    while (my $row = $csv->getline($ime_file)) {

        if ( $cond->{last_name} eq $row->[0] && $row->[2] eq '姓' ) {

            push @{ $res->{last_names} }, $row->[0] . ' ' . $row->[1];

        }

        if ( $cond->{first_name} eq $row->[0] && $row->[2] eq '名' ) {

            push @{ $res->{first_names} }, $row->[0] . ' ' . $row->[1];

        }
    }

    return $res;
}

1;
