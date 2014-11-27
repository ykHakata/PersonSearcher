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
Readonly my $RUBY      => 0;    # 'くさかべ'
Readonly my $KANZI     => 1;    # '日下部'
Readonly my $NAME_MODE => 2;    # '姓'
Readonly my $MODE      => 0;    # 'SEARCH_ALL'
Readonly my $NAME      => 1;    # 'くさかべ'

sub get_name_for_file {
    my $cond      = shift;

    die 'not cond value!'
        if !$cond->{last_name} || !$cond->{first_name} || !$cond->{file_path};

    my $res = +{
        last_names  => [],
        first_names => [],
    };

    # 二回ファイルを読み込んでいることになるので一回で済ませたい。
    $res = _get_search_name($cond);

    return $res;
}

sub _get_search_name {
    my $cond = shift;

    my $file_path = $cond->{file_path};

    my $name_mode = +{
        last_name  => '姓',
        first_name => '名',
    };

    my $res = +{
        last_names  => [],
        first_names => [],
    };

    return $res
        if $cond->{last_name}->[$MODE] eq 'NOT_SEARCH'
        && $cond->{first_name}->[$MODE] eq 'NOT_SEARCH';

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

        # 姓 名 の検索を同時に行う
        # 姓 読み方
        if ( $cond->{last_name}->[$MODE] eq 'SEARCH_ALL' ) {

            # 読み方を検索
            if (   $row->[$RUBY] eq $cond->{last_name}->[$NAME]
                && $row->[$NAME_MODE] eq $name_mode->{last_name} )
            {

                push @{ $res->{last_names} },
                    $row->[$RUBY] . ' ' . $row->[$KANZI];

            }
        }

        # 姓 漢字表示
        if (   $cond->{last_name}->[$MODE] eq 'SEARCH_ALL'
            || $cond->{last_name}->[$MODE] eq 'SEARCH_NAME_ONLY' )
        {

            # 漢字表示を検索
            if (   $row->[$KANZI] eq $cond->{last_name}->[$NAME]
                && $row->[$NAME_MODE] eq $name_mode->{last_name} )
            {

                push @{ $res->{last_names} },
                    $row->[$RUBY] . ' ' . $row->[$KANZI];

            }
        }

        # 名 読み方
        if ( $cond->{first_name}->[$MODE] eq 'SEARCH_ALL' ) {

            # 読み方を検索
            if (   $row->[$RUBY] eq $cond->{first_name}->[$NAME]
                && $row->[$NAME_MODE] eq $name_mode->{first_name} )
            {

                push @{ $res->{first_names} },
                    $row->[$RUBY] . ' ' . $row->[$KANZI];

            }
        }

        # 名 漢字表示
        if (   $cond->{first_name}->[$MODE] eq 'SEARCH_ALL'
            || $cond->{first_name}->[$MODE] eq 'SEARCH_NAME_ONLY' )
        {

            # 漢字表示を検索
            if (   $row->[$KANZI] eq $cond->{first_name}->[$NAME]
                && $row->[$NAME_MODE] eq $name_mode->{first_name} )
            {

                push @{ $res->{first_names} },
                    $row->[$RUBY] . ' ' . $row->[$KANZI];

            }
        }
    }
    close $ime_file;

    return $res;
}

1;
