package Software::Release::Watch;

# DATE
# VERSION

use 5.010001;
use Log::Any::IfLOG '$log';
use Moo;

use Perinci::Sub::Gen::AccessTable qw(gen_read_table_func);
use Software::Catalog;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(
                       list_software
                       list_software_releases
               );

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Watch latest software releases',
};

has mech => (
    is => 'rw',
    default => sub {
        require WWW::Mechanize;

        # to do automatic retry, pass a WWW::Mechanize::Pluggable object with
        # WWW::Mechanize::Plugin::Retry.

        WWW::Mechanize->new(autocheck=>0);
    },
);

sub get_url {
    my ($self, $url) = @_;

    my $resp = $self->mech->get($url);
    unless ($resp->is_success) {
        # 404 is permanent, otherwise we assume temporary error
        die [$resp->code == 404 ? 542 : 541,
             "Failed retrieving URL", undef,
             {
                 network_status  => $resp->code,
                 network_message => $resp->message,
                 url => $url,
             }];
    }
    $resp;
}

my $table_spec = {
    fields => {
        id => {
            index      => 0,
            schema     => ['str*' => {
                match => $Software::Catalog::swid_re,
            }],
            searchable => 1,
        },
    },
    pk => 'id',
};

my $res = gen_read_table_func(
    name => 'list_software',
    table_data => sub {
        require Module::List;

        my $query = shift;
        state $res = do {
            my $mods = Module::List::list_modules(
                "Software::Release::Watch::sw::", {list_modules=>1});
            $mods = [map {[[s/.+:://, $_]->[-1]]} keys %$mods];
            {data=>$mods, paged=>0, filtered=>0, sorted=>0, fields_selected=>0};
        };
        $res;
    },
    table_spec => $table_spec,
    langs => ['en_US'],
);
die "BUG: Can't generate func: $res->[0] - $res->[1]"
    unless $res->[0] == 200;

$SPEC{list_software_releases} = {
    v => 1.1,
    summary => 'List software releases',
    description => <<'_',

Statuses:

* 541 - transient network failure
* 542 - permanent network failure (e.g. server returns 404 page)
* 543 - parsing failure (permanent)

_
    args => {
        software_id => {
            schema => ["str*", {
                match => $Software::Catalog::swid_re,
            }],
            req => 1,
            pos => 0,
        },
    },
    "x.perinci.sub.wrapper.disable_validate_args" => 1,
};
sub list_software_releases {
    my %args = @_; # VALIDATE_ARGS
    my $swid = $args{software_id};

    my $res;

    $res = Software::Catalog::get_software_info(id => $swid);
    return $res unless $res->[0] == 200;

    my $mod = __PACKAGE__ . "::SW::$swid";
    my $mod_pm = $mod; $mod_pm =~ s!::!/!g; $mod_pm .= ".pm";
    eval { require $mod_pm };
    return [500, "Can't load $mod: $@"] if $@;

    my $obj = $mod->new(watcher => __PACKAGE__->new);

    $res = eval { $obj->list_releases };
    my $err = $@;

    if ($err) {
        if (ref($err) eq 'ARRAY') {
            return $err;
        } else {
            return [500, "Died: $err"];
        }
    } else {
        return [200, "OK", $res];
    }
}

1;
# ABSTRACT:

=for Pod::Coverage get_url mech

=head1 SYNOPSIS

 use Software::Release::Watch qw(
     list_software
     list_software_releases
 );

 my $res;
 $res = list_software();
 $res = list_software_releases(software_id=>'wordpress');


=head1 FAQ


=head1 SEE ALSO

L<Software::Catalog>

C<Software::Release::Watch::*> modules.

=cut
