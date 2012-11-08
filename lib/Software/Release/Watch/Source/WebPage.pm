package Software::Release::Watch::Source::WebPage;

use 5.010;
use Moo::Role;

# VERSION

requires "url";
requires "parse_html";

sub list_releases {
    my $self = shift;

    my $w    = $self->watcher;
    my $resp = $w->get_url($self->url);

    my $ct = $resp->content_type;
    die [542, "URL not a web (HTML) page ($ct)", undef] unless $ct =~ /html/;
    $self->parse_html($resp->content);
}

1;
# ABSTRACT: Get releases from web page
