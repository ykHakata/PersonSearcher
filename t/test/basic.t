use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use URI::Escape;

my $t = Test::Mojo->new('PersonSearcher');

# 人名検索画面テスト(開発用)
$t->get_ok('/index.html')->status_is(200);

my $router_css = '/import.css';

my $index_html_contents = [
    '<title>人名検索</title>',
    '人名検索',
    '姓', '名',
    'くさかべ', 'ゆきお',
    '実行',
    '検索結果\(姓\)', '検索結果\(名\)',
    'くさかべ 日壁', 'ゆきお 雪雄',
    'くさかべ 日下邊', 'ゆきお 之男',
    'くさかべ 日下部', 'ゆきお 幸夫',
    # css読み込み
    q{<link rel="stylesheet" href="} . $router_css . q{">},
];

for my $index_html_content (@{$index_html_contents}) {
    $t->content_like(qr/$index_html_content/i);
}

# スタイルシート、import設置(今回はすべてを記述)
$t->get_ok($router_css)->status_is(200);

my $import_css_contents = [
    # reset.css
    'Last Up Date 2014/11/08',
    'body,div,dl,dt,dd,ul,ol,li,',
    # header.css
    '#header',
    # contents.css
    '#contents',
    # footer.css
    '#footer',
];

for my $import_css_content (@{$import_css_contents}) {
    $t->content_like(qr/$import_css_content/i);
}

# テンプレートにindex.htmlファイルを移植
# 入力フォームを有効、初期アクセスは値なし
$t->get_ok('/')->status_is(200);

# テスト用文字定義
my $index_temp_contents = $index_html_contents;

# 確認用の追加文字
push @{$index_temp_contents},
    # headの記述を正確に
    '<meta charset="utf-8">',
    '<meta http-equiv="X-UA-Compatible" content="IE=edge">',
    # フッターの文字を変更
    'PersonSearch in Mojolicious',
    # 入力フォームのname
    q{name="lastName"}, q{name="firstName"},
;

# 入力フォームや検索結果に値があってはいけない
my @unlike_list = (
    'くさかべ', 'ゆきお',
    'くさかべ 日壁', 'ゆきお 雪雄',
    'くさかべ 日下邊', 'ゆきお 之男',
    'くさかべ 日下部', 'ゆきお 幸夫',
);

for my $index_temp_content (@{$index_temp_contents}) {
    if (grep { $_ eq $index_temp_content } @unlike_list) {
        $t->content_unlike(qr/$index_temp_content/i);
    }
    else {
        $t->content_like(qr/$index_temp_content/i);
    }
}

# スタイルシート読み込み確認
$t->get_ok($router_css)->status_is(200);

for my $import_css_content (@{$import_css_contents}) {
    $t->content_like(qr/$import_css_content/i);
}

# WebSearch.pm
my $last_name = URI::Escape::uri_escape_utf8(qq{くさかべ});
my $first_name = URI::Escape::uri_escape_utf8(qq{ゆきお});

# 入力フォームからの検索実行
$t->get_ok("/?lastName=${last_name}&firstName=${first_name}")->status_is(200);

# ime-import.txt の生データを定義
my $search_name_list = [
    # 姓の該当データ
    'くさかべ 日壁', 'くさかべ 日下邊', 'くさかべ 日下辺', 'くさかべ 草下部',
    'くさかべ 日下部', 'くさかべ 草壁', 'くさかべ 草部',
    # 名の該当データ
    # これは姓になっている
    # ゆきお 由木尾 姓
    # ゆきお 雪尾  姓
    'ゆきお 征夫', 'ゆきお 由希夫', 'ゆきお 之雄', 'ゆきお 之夫',
    'ゆきお 之男', 'ゆきお 之生', 'ゆきお 雪雄', 'ゆきお 雪夫',
    'ゆきお 雪男', 'ゆきお 雪生', 'ゆきお 由紀生', 'ゆきお 由紀男',
    'ゆきお 由紀夫', 'ゆきお 雄幸', 'ゆきお 裕希雄', 'ゆきお 由木男',
    'ゆきお 由起雄', 'ゆきお 由起夫', 'ゆきお 由起男', 'ゆきお 由貴雄',
    'ゆきお 由記雄', 'ゆきお 由紀雄', 'ゆきお 征雄', 'ゆきお 行夫',
    'ゆきお 幸勇', 'ゆきお 幸夫', 'ゆきお 幸男', 'ゆきお 幸生',
    'ゆきお 幸緒', 'ゆきお 幸央', 'ゆきお 敬雄', 'ゆきお 敬生',
    'ゆきお 維郎', 'ゆきお 悠紀雄', 'ゆきお 幸雄', 'ゆきお 幸朗',
    'ゆきお 征男', 'ゆきお 征生', 'ゆきお 修恵', 'ゆきお 志雄',
    'ゆきお 行郎', 'ゆきお 行雄', 'ゆきお 行男', 'ゆきお 行生',
    'ゆきお 行央', 'ゆきお 雪緒', 'ゆきお 透雄', 'ゆきお 征勇',
    'ゆきお 有紀男', 'ゆきお 有幹生',
];

# 検索結果の名前確認
for my $search_name (@{$search_name_list}) {
    $t->content_like(qr/$search_name/i);
}

# 空にして実行
$t->get_ok('/?lastName=&firstName=')->status_is(200);

# 検索結果の名前確認(なにも表示されない)
for my $search_name (@{$search_name_list}) {
    $t->content_unlike(qr/$search_name/i);
}

# 入力フォームからの検索実行(lastNameのみ)
$t->get_ok("/?lastName=${last_name}&firstName=")->status_is(200);

# 検索結果にfirstNameの値があってはいけない
my @firstName_list = (
    'ゆきお 征夫', 'ゆきお 由希夫', 'ゆきお 之雄', 'ゆきお 之夫',
    'ゆきお 之男', 'ゆきお 之生', 'ゆきお 雪雄', 'ゆきお 雪夫',
    'ゆきお 雪男', 'ゆきお 雪生', 'ゆきお 由紀生', 'ゆきお 由紀男',
    'ゆきお 由紀夫', 'ゆきお 雄幸', 'ゆきお 裕希雄', 'ゆきお 由木男',
    'ゆきお 由起雄', 'ゆきお 由起夫', 'ゆきお 由起男', 'ゆきお 由貴雄',
    'ゆきお 由記雄', 'ゆきお 由紀雄', 'ゆきお 征雄', 'ゆきお 行夫',
    'ゆきお 幸勇', 'ゆきお 幸夫', 'ゆきお 幸男', 'ゆきお 幸生',
    'ゆきお 幸緒', 'ゆきお 幸央', 'ゆきお 敬雄', 'ゆきお 敬生',
    'ゆきお 維郎', 'ゆきお 悠紀雄', 'ゆきお 幸雄', 'ゆきお 幸朗',
    'ゆきお 征男', 'ゆきお 征生', 'ゆきお 修恵', 'ゆきお 志雄',
    'ゆきお 行郎', 'ゆきお 行雄', 'ゆきお 行男', 'ゆきお 行生',
    'ゆきお 行央', 'ゆきお 雪緒', 'ゆきお 透雄', 'ゆきお 征勇',
    'ゆきお 有紀男', 'ゆきお 有幹生',
);

# 値の出力確認
for my $search_name (@{$search_name_list}) {
    if (grep { $_ eq $search_name } @firstName_list) {
        $t->content_unlike(qr/$search_name/i);
    }
    else {
        $t->content_like(qr/$search_name/i);
    }
}

# 入力フォームからの検索実行(firstNameのみ)
$t->get_ok("/?lastName=&firstName=${first_name}")->status_is(200);

# 検索結果にlastNameの値があってはいけない
my @lastName_list = (
    'くさかべ 日壁', 'くさかべ 日下邊', 'くさかべ 日下辺', 'くさかべ 草下部',
    'くさかべ 日下部', 'くさかべ 草壁', 'くさかべ 草部',
);

# 値の出力確認
for my $search_name (@{$search_name_list}) {
    if (grep { $_ eq $search_name } @lastName_list) {
        $t->content_unlike(qr/$search_name/i);
    }
    else {
        $t->content_like(qr/$search_name/i);
    }
}

done_testing();
