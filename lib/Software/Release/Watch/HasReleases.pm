package Software::Release::Watch::HasReleases;

use 5.010;
use Moo::Role;

# VERSION

sub parse_filename {
    my $self = shift;

    $self->get_url($self->releases_url);
    # find links that look like an archive
}

sub archive_ext_re {
    state $re = /\.(tar\.(?:gz|bz2|xz)|tar|zip|rar)\z/i;
    $re;
}

sub url_looks_like_filename {
    my ($self, $url) = @_;
}

sub filename_looks_like_archive {
    my ($self, $url) = @_;
}

sub list_releases {
}

1;
