package Software::Release::Watch::Software;

use 5.010;
use Moo::Role;

# VERSION

has watcher => (is => 'rw', required => 1);
requires 'list_releases';

1;
# ABSTRACT: Software role

=cut
