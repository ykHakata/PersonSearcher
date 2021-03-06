package PersonSearcher;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  $r->get('/')->to( controller => 'web_search', action => 'search');
}

1;

__END__

=encoding utf8

=head1 NAME

PersonSearcher - 人名検索をするWEBアプリケーション

=head1 DEPENDENCIES

=over 2

=item * L<Mojo::Base>

=item * L<Mojolicious>

=item * L<Mojolicious::Plugin::PODRenderer>

=back

=head1 SEE ALSO

L<PersonSearcher::Guides>
