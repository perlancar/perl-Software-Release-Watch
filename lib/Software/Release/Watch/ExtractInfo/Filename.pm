package Software::Release::Watch::ExtractInfo::Filename;

use 5.010;
use Log::Any '$log';
use Moo::Role;

# VERSION

#my @archive_exts = qw(tar.gz tar.bz2 tar zip rar);
#my $archive_re   = join("|", map {quotemeta} @archive_exts);
#$archive_re = qr/\.$archive_re$/i;

# XXX some software use _ (or perhaps space) to separate name and
# version

sub extract_info {
    my ($sel, $fn) = @_;

    unless ($fn =~ /\A(.+)-([0-9].+)\z/) {
        $log->warnf("Can't parse filename: %s", $fn);
        return;
    }

    {name=>$1, v=>$2};
}

1;
# ABSTRACT: Parse releases from name like 'NAME-VERSION'

=for Pod::Coverage extract_info
