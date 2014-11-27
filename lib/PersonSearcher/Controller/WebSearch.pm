package PersonSearcher::Controller::WebSearch;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub search {
    my $self = shift;

    $self->render( template => 'index');
}

1;
