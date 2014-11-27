use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PersonSearcher');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

# 人名検索画面テスト(開発用)
my $index_test = $t->get_ok('/index.html')->status_is(200);

my $contents = [
    '<title>人名検索</title>',
    '人名検索',
    '姓', '名',
    'くさかべ', 'ゆきお',
    '実行',
    '検索結果\(姓\)', '検索結果\(名\)',
    'くさかべ 日壁', 'ゆきお 雪雄',
    'くさかべ 日下邊', 'ゆきお 之男',
    'くさかべ 日下部', 'ゆきお 幸夫',
];

for my $content (@{$contents}) {
    $index_test->content_like(qr/$content/i);
}

done_testing();
