use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PersonSearcher');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

# 人名検索画面テスト(開発用)
my $index_test = $t->get_ok('/index.html')->status_is(200);

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
    '<link rel="stylesheet" href="/css/import.css">',
];

for my $index_html_content (@{$index_html_contents}) {
    $index_test->content_like(qr/$index_html_content/i);
}

# スタイルシート、import設置(今回はすべてを記述)
$t->get_ok('/css/import.css')->status_is(200);

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
    $index_test->content_like(qr/$import_css_content/i);
}

done_testing();
