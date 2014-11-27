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
            last_name  => [ SEARCH_ALL => '' ],
            first_name => [ SEARCH_ALL => '' ],
            file_path  => '',
        },
        stash_value => +{
            last_names  => [],
            first_names => [],
        },
    };

    # 例:
    #     search_value => +{
    #         last_name  => [ SEARCH_ALL => 'くさかべ' ],
    #       # last_name  => [ NOT_SEARCH => '' ],
    #       # last_name  => [ SEARCH_NAME_ONLY => '日下部' ],
    #     },

    my $req    = $self->req;
    my $params = $req->params->to_hash;

    my $validator = FormValidator::Lite->new($req);
    $validator->check(
        lastName  => [qw/NOT_NULL HIRAGANA/],
        firstName => [qw/NOT_NULL HIRAGANA/],
    );

    $cond->{search_value}->{last_name}->[1]  = $params->{lastName};
    $cond->{search_value}->{first_name}->[1] = $params->{firstName};

    if ( $validator->has_error() ) {

        my $errors = $validator->errors();

        if ( exists $errors->{lastName} ) {
            my ($error_key) = keys %{ $errors->{lastName} };

            $cond->{search_value}->{last_name}
                = $error_key eq 'NOT_NULL' ? [ NOT_SEARCH       => '' ]
                : $error_key eq 'HIRAGANA' ? [ SEARCH_NAME_ONLY => '' ]
                :                            [ SEARCH_ALL       => '' ];

            $cond->{search_value}->{last_name}->[1] = $params->{lastName};
        }

        if ( exists $errors->{firstName} ) {
            my ($error_key) = keys %{ $errors->{firstName} };

            $cond->{search_value}->{first_name}
                = $error_key eq 'NOT_NULL' ? [ NOT_SEARCH       => '' ]
                : $error_key eq 'HIRAGANA' ? [ SEARCH_NAME_ONLY => '' ]
                :                            [ SEARCH_ALL       => '' ];

            $cond->{search_value}->{first_name}->[1] = $params->{firstName};
        }
    }

    $self->stash( $cond->{stash_value} );

    return $self->render( template => 'index' )
        if $cond->{search_value}->{last_name}->[0] eq 'NOT_SEARCH'
        && $cond->{search_value}->{first_name}->[0] eq 'NOT_SEARCH';

    $cond->{search_value}->{file_path}
        = $self->app->home->rel_file('lib/PersonSearcher/Model/ime-import.txt');

    $cond->{stash_value}
        = get_name_for_file( $cond->{search_value} );

    $self->stash( $cond->{stash_value} );

    return $self->render( template => 'index' );
}

1;
