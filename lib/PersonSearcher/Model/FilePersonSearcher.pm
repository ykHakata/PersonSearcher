package PersonSearcher::Model::FilePersonSearcher;

use strict;
use warnings;
use utf8;
use open OUT => qw/:utf8 :std/;
use English;
use Text::CSV;
use Exporter 'import';
our @EXPORT_OK = qw{get_name_for_file};

# use Smart::Comments;

sub get_name_for_file {
    my $cond      = shift;

    my $last_name  = $cond->{last_name};
    my $first_name = $cond->{first_name};
    my $file_path  = $cond->{file_path};

    die 'not cond value!' if !$last_name || !$first_name || !$file_path;
    my $res = +{
        last_names  => [],
        first_names => [],
    };

    ### 引数の形式が変更になったので暫定的にここで変換
    $cond->{last_name}  = $cond->{last_name}->[1];
    $cond->{first_name} = $cond->{first_name}->[1];

    my $csv = Text::CSV->new(+{
        binary   => 1,
        sep_char => "\t",
    });

    open my $ime_file, '<:encoding(utf8)', $file_path
        or die "no file $OS_ERROR";

    while ( my $row = $csv->getline($ime_file) ) {

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
