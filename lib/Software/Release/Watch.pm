package Software::Release::Watch;

use 5.010;
use Log::Any '$log';
use Moo;

use Perinci::Sub::Gen::AccessTable 0.17 qw(gen_read_table_func);
use Software::Catalog;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(
                       list_software
                       list_software_releases
               );

# VERSION

our %SPEC;

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
    [200, "OK", $resp];
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
            my $mods = Module::List::list_modules("Software::Release::Watch::",
                                              {list_modules=>1});
            use Data::Dump; dd $mods;
            $mods = [map {[[s/.+:://, $_]->[-1]]}
                         grep {/::[a-z]\w*$/} (sort keys %$mods)];
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
    summary => 'List software releases',
    args => {
        software_id => {
            schema => ["int*", {
                match => Software::Catalog::swid_re,
            }],
            req => 1,
            pos => 0,
        },
    },
    "_perinci.sub.wrapper.validate_args" => 0,
};
sub list_software_releases {
    my %args = @_; # VALIDATE_ARGS
    my $swid = $args{software_id};

    my $res;

    $res = Software::Catalog::get_software_info(id => $swid);
    return $res unless $res->[0] == 200;

    my $mod = __PACKAGE__ . "::$swid";
    my $mod_pm = $mod; $mod_pm =~ s!::!/!g; $mod_pm .= ".pm";
    eval { require $mod_pm };
    return [500, "Can't load $mod: $@"] if $@;

    my $obj = $mod->new;
    $obj->list_releases;
}

1;
# ABSTRACT: Watch latest software releases

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

