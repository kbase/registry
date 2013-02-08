use strict;
use Data::Dumper;
use Carp;


use Bio::KBase::ServiceRegistry::Client;
use JSON -support_by_pp;;

use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;
my %ref;
	
GetOptions('h'              => \$help,
	   'help'           => \$help,
	   'man'            => \$man,
#	   'idd=s'          => \$ref{idd},
#	   'service_name=s' => \$ref{service_name},
#	   'namespace=s'    => \$ref{namespace},
	   'hostname=s'     => \$ref{hostname},
	   'port=i'         => \$ref{port},
#	   'ip_allows=s@'   => \@{$ref{ip_allows}},
    ) or pod2usage(2);
pod2usage(-exitstatus => 0, -verbose => 2) if $help or $man;

# To delete a service, we need either the service id as declared
# in the mongo database, or the hostname and port. We can require
# more than the hostname and port to make sure the user knows
# what they are asking for. 
my $message_text = "incorrect parameters";
pod2usage (-exitstatus => 0, -verbose => 2, -message => $message_text)
    unless ((exists $ref{mongo_id} and defined $ref{mongo_id} )  or 
	    ((exists $ref{hostname} and defined $ref{hostname})  and
	     (exists $ref{port}     and defined $ref{port})));

my $r = Bio::KBase::ServiceRegistry::Client();
$r->deregister_service(\%ref);












=head1 NAME:

deregister_service

=head1 SYNOPSIS:

deregister_service.pl --hostname localhost           \
                      --port 22                      \
                      --service_name ServiceRegistry \

=head1 DESCRIPTION

The register_service command is used to register information about
a service. This should be used at deploy time or when a service is
started.
    
=head1 Command-line Options:

To delete a service, we need either the service id as declared
in the mongo database, or the hostname and port. We can require
more than the hostname and port to make sure the user knows
what they are asking for. 

=over

=item    -h, --help, --man  This documentation

=item    --hostname         The host on which the service is running

=item    --port             The port assigned to the service

=item    --service_name     The name of the running service. This is the name of the service as declared in the module declaration of the service's interface description document. This is optional right now.

=back

=head1 AUTHORS

Thomas Brettin

=cut
