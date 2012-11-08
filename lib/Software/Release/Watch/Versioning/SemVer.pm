package Software::Release::Watch::Versioning::SemVer;

use 5.010;
use Moo::Role;

use SemVer;

# VERSION

sub cmp_version {
    my ($a, $b) = @_;
    SemVer->new($a) <=> SemVer->new($b);
}

1;
# ABSTRACT: Semantic versioning as per semver.org

=for Pod::Coverage cmp_version
