package PersonSearcher::Controller::WebSearch;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
    FormValidator::Lite->load_constraints(qw/Japanese/);
use PersonSearcher::Model::FilePersonSearcher qw{get_name_for_file};

# use Smart::Comments;

sub search {
    my $self = shift;

    my $cond = +{
        search_value => +{
            last_name  => '',
            first_name => '',
        },
        stash_value => +{
            last_names  => [],
            first_names => [],
        },
    };

    my $req    = $self->req;
    my $params = $req->params->to_hash;

    my $validator = FormValidator::Lite->new($req);
    $validator->check(
        lastName  => [ 'HIRAGANA' ],
        firstName => [ 'HIRAGANA' ],
    );

    $self->stash( $cond->{stash_value} );

    return $self->render( template => 'index' )
        if !$params->{lastName} && !$params->{firstName};

    return $self->render( template => 'index' ) if $validator->has_error();

    $cond->{search_value}->{last_name}  = $params->{lastName};
    $cond->{search_value}->{first_name} = $params->{firstName};

    $cond->{stash_value} = get_name_for_file( $cond->{search_value} );

    $self->stash( $cond->{stash_value} );

    return $self->render( template => 'index' );
}

1;
