use strict;
use Data::Dumper;
use Carp;


use Bio::KBase::ServiceRegistry::Client;
use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;
	
GetOptions('h'              => \$help,
	   'help'           => \$help,
	   'man'            => \$man,
    ) or pod2usage(2);
pod2usage(-exitstatus => 0, -verbose => 2) if $help or $man;

# set package variables
our $cfg = {};
if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) {
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG}) or
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => Config::Simple->error(),
                                                         method_name => 'new');
}
else {
    $cfg = new Config::Simple(syntax=>'ini') or
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error => Config::Simple->error(),
                                                         method_name => 'new'); 
    $cfg->param('registry.mongodb-host', 'localhost');
    $cfg->param('registry.mongodb-db', 'registry');
    $cfg->param('registry.mongodb-collection', 'test');
    $cfg->param('registry.service-host', '127.0.0.1');
    $cfg->param('registry.service-port', '7070');
}
my $service_url = "http://" . $cfg->param('registry.service-host') . ":" .
	$cfg->param('registry.service-port');
my $r = Bio::KBase::ServiceRegistry::Client->new($service_url);
my $services = $r->enumerate_services();
foreach my $service_info (@$services) {
  print Dumper $service_info;
}

=pod

=head1	NAME

=head1	SYNOPSIS

=head1	DESCRIPTION

=head1	COMMAND-LINE OPTIONS

=over

=item

=back

=head1	AUTHORS
Thomas Brettin

=cut






=head1 NAME:

    register_service

=head1 SYNOPSIS:

    register_service.pl --hostname localhost           \
                        --port 22                      \
                        --service_name ServiceRegistry \




=head1 DESCRIPTION

The register_service command is used to register information about
a service. This should be used at deploy time or when a service is
started.
    
=head1 Command-line Options:

=over

=item    -h, --help, --man  This documentation

=item    --hostname         The host on which the service is running

=item    --port             The port assigned to the service

=item    --service_name     The name of the running service. This is the name of the service as declared in the module declaration of the service's interface description document. This is optional right now.

=back

=head1 AUTHORS

=over

=item Tom Brettin

=back

=cut
