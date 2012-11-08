package Software::Release::Watch::HasReleasesInURL;

use 5.010;
use Moo::Role;

# VERSION

requires "releases_url";

with "Software::Release::Watch::HasReleases";

sub get_releases {
    my $self = shift;

    $self->get_url($self->releases_url);
    # parse html
    # find links that look like an archive
}

sub parse_html {
}

1;
