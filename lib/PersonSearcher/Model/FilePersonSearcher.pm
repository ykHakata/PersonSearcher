package PersonSearcher::Model::FilePersonSearcher;

use strict;
use warnings;
use utf8;
use open OUT => qw/:utf8 :std/;
use English;
use Text::CSV;
use Readonly;
use Exporter 'import';
our @EXPORT_OK = qw{get_name_for_file};

# use Smart::Comments;

# 数字の指定はわかりにくいので定数を定義
# $row->[0] は読み方 $row->[1] は漢字表示 $row->[2] は 姓、名
Readonly my $RUBY      => 0;
Readonly my $KANZI     => 1;
Readonly my $NAME_MODE => 2;

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
        = _get_search_name_array( $file_path, $last_name, 'last_name' );

    $res->{first_names}
        = _get_search_name_array( $file_path, $first_name, 'first_name' );

    return $res;
}

sub _get_search_name_array {
    my $file_path   = shift;
    my $name_cond   = shift;    # [ SEARCH_ALL => 'くさかべ' ]
    my $name_mode_q = shift;    # 'last_name'

    my $mode = $name_cond->[0];    # 'SEARCH_ALL'
    my $name = $name_cond->[1];    # 'くさかべ'

    my $name_mode = +{
        last_name  => '姓',
        first_name => '名',
    };

    my $res = [];

    return $res if $mode eq 'NOT_SEARCH';

    open my $ime_file, '<:encoding(utf8)', $file_path
        or die "no file $OS_ERROR";

    my $csv = Text::CSV->new(+{
        binary   => 1,
        sep_char => "\t",
    });

    SEARCH_NAME:
    while ( my $row = $csv->getline($ime_file) ) {

        # タブ区切りの状態が正しくないときはスキップ
        next SEARCH_NAME if !$row->[$RUBY] || !$row->[$KANZI];

        if ( $mode eq 'SEARCH_ALL' ) {

            # 読み方を検索
            if (   $row->[$RUBY]      eq $name
                && $row->[$NAME_MODE] eq $name_mode->{$name_mode_q} )
            {

                push @{$res}, $row->[$RUBY] . ' ' . $row->[$KANZI];

            }
        }

        if ( $mode eq 'SEARCH_ALL' || $mode eq 'SEARCH_NAME_ONLY' ) {

            # 漢字表示を検索
            if (   $row->[$KANZI]     eq $name
                && $row->[$NAME_MODE] eq $name_mode->{$name_mode_q} )
            {

                push @{$res}, $row->[$RUBY] . ' ' . $row->[$KANZI];

            }
        }
    }
    close $ime_file;

    return $res;
}

1;
