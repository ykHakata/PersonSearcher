package PersonSearcher::Controller::WebSearch;
use Mojo::Base 'Mojolicious::Controller';

use FormValidator::Lite;

use Data::Dumper;

sub search {
    my $self = shift;

    my $req = $self->req;

    # パラメーター受け取り
    my $params = $req->params->to_hash;

    my $validator = FormValidator::Lite->new($req);

    $validator->check(
        lastName  => [ 'REQUIRED', [ EQUAL => 'くさかべ' ] ],
        firstName => [ 'REQUIRED', [ EQUAL => 'ゆきお'   ] ],
    );

    # 出力する値を定義
    my $last_names = [
        'くさかべ 日壁',
        'くさかべ 日下邊',
        'くさかべ 日下部',
    ];
    my $first_names = [
        'ゆきお 雪雄',
        'ゆきお 之男',
        'ゆきお 幸夫',
    ];
    my $space = [];

    if ( $validator->is_error('lastName') ) {
        $last_names = $space;
    }

    if ( $validator->is_error('firstName') ) {
        $first_names = $space;
    }

    # 出力する値を固定値で作り込み
    $self->stash(+{
        last_names  => $last_names,
        first_names => $first_names,
    });

    return $self->render( template => 'index');
}

1;
