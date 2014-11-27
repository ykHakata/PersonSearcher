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

    $res->{last_names}
        = _get_name_array( $file_path, $last_name, 'last_name' );

    $res->{first_names}
        = _get_name_array( $file_path, $first_name, 'first_name' );

    return $res;
}

sub _get_name_array {
    my $file_path = shift;
    my $name_cond = shift;    # [ SEARCH_ALL => 'くさかべ' ]
    my $name_mode = shift;    # 'last_name'

    my $mode = $name_cond->[0];    # 'SEARCH_ALL'
    my $name = $name_cond->[1];    # 'くさかべ'

    my $res = [];

    if ( $mode eq 'SEARCH_ALL' ) {
        $res = _get_search_all( $file_path, $name, $name_mode );
    }
    elsif ( $mode eq 'NOT_SEARCH' ) {
        $res = _get_not_search();
    }
    elsif ( $mode eq 'SEARCH_NAME_ONLY' ) {
        $res = _get_search_name_only( $file_path, $name, $name_mode );
    }
    else {
        $res = [];
    }

    return $res;
}

sub _get_search_all {
    my $file_path   = shift;
    my $name        = shift;    # 'くさかべ'
    my $name_mode_q = shift;    # 'last_name'

    my $name_mode = +{
        last_name  => '姓',
        first_name => '名',
    };

    my $res = [];

    open my $ime_file, '<:encoding(utf8)', $file_path
        or die "no file $OS_ERROR";

    my $csv = Text::CSV->new(+{
        binary   => 1,
        sep_char => "\t",
    });

    # $row->[0] は読み方 $row->[1] は漢字表示 $row->[2] は 姓、名
    SEARCH_NAME:
    while ( my $row = $csv->getline($ime_file) ) {

        # タブ区切りの状態が正しくないときはスキップ
        next SEARCH_NAME if !$row->[0] || !$row->[1];

        # 読み方を検索
        if ( $name eq $row->[0] && $row->[2] eq $name_mode->{$name_mode_q} ) {

            push @{$res}, $row->[0] . ' ' . $row->[1];

        }

        # 漢字表示を検索
        if ( $name eq $row->[1] && $row->[2] eq $name_mode->{$name_mode_q} ) {

            push @{$res}, $row->[0] . ' ' . $row->[1];

        }

    }
    close $ime_file;

    return $res;
}

sub _get_not_search {
    my $res = [];

    return $res;
}

sub _get_search_name_only {
    my $file_path   = shift;
    my $name        = shift;    # '日下部'
    my $name_mode_q = shift;    # 'last_name'

    my $name_mode = +{
        last_name  => '姓',
        first_name => '名',
    };

    my $res = [];

    open my $ime_file, '<:encoding(utf8)', $file_path
        or die "no file $OS_ERROR";

    my $csv = Text::CSV->new(+{
        binary   => 1,
        sep_char => "\t",
    });

    # $row->[0] は読み方 $row->[1] は漢字表示 $row->[2] は 姓、名
    SEARCH_NAME:
    while ( my $row = $csv->getline($ime_file) ) {

        # タブ区切りの状態が正しくないときはスキップ
        next SEARCH_NAME if !$row->[0] || !$row->[1];

        # 漢字表示を検索
        if ( $name eq $row->[1] && $row->[2] eq $name_mode->{$name_mode_q} ) {

            push @{$res}, $row->[0] . ' ' . $row->[1];

        }
    }
    close $ime_file;

    return $res;
}

1;
