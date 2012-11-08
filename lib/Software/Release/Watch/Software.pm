package Software::Release::Watch::Software;

use 5.010;
use Moo::Role;

# VERSION

has watcher => (is => 'rw', required => 1);

requires 'list_releases';

#with 'Software::Release::Watch::Versioning';
requires 'cmp_version';

1;
# ABSTRACT: Software role
