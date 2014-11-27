use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

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

# 入力フォームからの検索実行
$t->get_ok('/?lastName=くさかべ&firstName=ゆきお')->status_is(200);

# 値の出力確認
for my $index_temp_content (@{$index_temp_contents}) {
    $t->content_like(qr/$index_temp_content/i);
}

# 入力フォームからの検索実行(lastNameのみ)
$t->get_ok('/?lastName=くさかべ&firstName=')->status_is(200);

# 検索結果にfirstNameの値があってはいけない
my @firstName_list = (
    'ゆきお',
    'ゆきお 雪雄',
    'ゆきお 之男',
    'ゆきお 幸夫',
);

# 値の出力確認
for my $index_temp_content (@{$index_temp_contents}) {
    if (grep { $_ eq $index_temp_content } @firstName_list) {
        $t->content_unlike(qr/$index_temp_content/i);
    }
    else {
        $t->content_like(qr/$index_temp_content/i);
    }
}

# 入力フォームからの検索実行(firstNameのみ)
$t->get_ok('/?lastName=&firstName=ゆきお')->status_is(200);

# 検索結果にlastNameの値があってはいけない
my @lastName_list = (
    'くさかべ',
    'くさかべ 日壁',
    'くさかべ 日下邊',
    'くさかべ 日下部',
);

# 値の出力確認
for my $index_temp_content (@{$index_temp_contents}) {
    if (grep { $_ eq $index_temp_content } @lastName_list) {
        $t->content_unlike(qr/$index_temp_content/i);
    }
    else {
        $t->content_like(qr/$index_temp_content/i);
    }
}

done_testing();
