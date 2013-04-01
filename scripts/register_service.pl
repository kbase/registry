use strict;
use Data::Dumper;
use Carp;

use Bio::KBase::ServiceRegistry::Client;
use JSON -support_by_pp;;

use Getopt::Long;
use Pod::Usage;

# set package variables
use Config::Simple ('-lc'); # ignoring case, don't save to file.
our $cfg = {};
if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) {
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG});
}
else {
    $cfg = new Config::Simple(syntax=>'ini');
    $cfg->param('registry.service-host', '127.0.0.1');
    $cfg->param('registry.service-port', '7070');
    $cfg->param('registry.service-url', 'http://localhost:7070');
}

my $man = 0;
my $help = 0;
my $infile;
my %ref;

GetOptions('h'              => \$help,
	   'help'           => \$help,
	   'man'            => \$man,
	   'idd=s'          => \$ref{idd},
	   'service_name=s' => \$ref{service_name},
	   'namespace=s'    => \$ref{namespace},
	   'hostname=s'     => \$ref{hostname},
	   'port=i'         => \$ref{port},
	   'ip_allows=s@'   => \@{$ref{ip_allows}},
    ) or pod2usage(2);
pod2usage(-exitstatus => 0, -verbose => 2) if $help or $man;
pod2usage(-exitstatus => 0, -verbose => 2) unless
	defined $ref{service_name} and
	defined $ref{namespace} and
	defined $ref{hostname} and
	defined $ref{port};

# need some logic here to keep the user from doing the wrong
# thing with the arguments


# you can pass the name of the idd document in on the command line
my $idd_string;
if ($ref{idd} and -e $ref{idd} ) {
    open IDD, "$ref{idd}" or die "cannot open $ref{idd}";
    $idd_string .= $_ while(<IDD>);
    close IDD;
    $ref{idd} = $idd_string;
    print to_json(\%ref, {ascii => 1, pretty => 1});
}

my $r = Bio::KBase::ServiceRegistry::Client->new($cfg->param('registry.service-url'));
print Dumper(\%ref) and exit;












=head1 NAME:

register_service

=head1 SYNOPSIS:

register_service.pl --hostname localhost           \
                    --port 22                      \
                    --service_name ServiceRegistry \
                    --namespace test               \
                    --idd ../ServiceRegistry.spec  \
                    --ip_allows 127.0.0.1          \
                    --ip_allows 192.168.1.100 



=head1 DESCRIPTION

The register_service command is used to register information about
a service. This should be used at deploy time or when a service is
started.

=head1 COMMAND-LINE OPTIONS

=over

=item -h, --help, --man  This documentation

=item --hostname         The host on which the service is running

=item --port             The port assigned to the service

=item --service_name     The name of the service as declared in the IDD.

=item --namespace        The type of service, such as prod, test, dev.

=item --idd              The interface description document (IDD) for the service. This is a fully qualified filename.

=item --ip_allows        IP addresses of hosts that we ant to allow access to the service

=back

=head2 Service JSON Document Schema

The JSON Document schema describes the internal data structure that is created from the command line arguements. It is here for reference.

{
        "title": "Registry Schema",
        "type": "object",
        "properties": {
                "idd": {
                        "type": "string"
                },
                "service_name": {
                        "type": "string"
                },
                "namespace": {
                        "type": "string"
                },
                "hostname": {
                        "type": "string"
                },
                "port": {
                        "type": "integer"
                },
                "ip_allows": {
                        "type": "array",
                        "items": {
                                "type": "object",
                                "properties": {
                                        "ip_address": {
                                                "type": "string"
                                        }
                                }
                        }
                }
        "required": ["service_name","namespace","host_name","service_port"]
}



=head1 AUTHORS

Thomas Brettin

=cut
