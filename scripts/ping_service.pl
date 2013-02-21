use strict;
use Data::Dumper;
use Carp;

use Bio::KBase::ServiceRegistry::Client;
use Getopt::Long;
use Pod::Usage;

my $man  = 0;
my $help = 0;
my $url = "";

GetOptions('h'              => \$help,
	   'help'           => \$help,
	   'man'            => \$man,
           'url'            => \$url,
    ) or pod2usage(2);
pod2usage(-exitstatus => 0, -verbose => 2) if $help or $man;
pod2usage(-msg => "no service url provided",
          -exitstatus => 0, -verbose => 2) unless $url;

# do a little validation on the service url provided
# does it have a protocol
# does it have a port number

my $r = Bio::KBase::ServiceRegistry::Client->new("http://localhost:7070");
my $result = $r->is_alive($url);
print $result, "\n";

=pod

=head1	NAME

is_alive

=head1	SYNOPSIS

is_alive --url "http://kbase.us/services/ontology_service"
is_alive --help

=head1	DESCRIPTION

The is_alive script prints out to STDOUT the return value of the is_alive
function. This is a boolean, 0 or 1. 

=head1	COMMAND-LINE OPTIONS

=over

=item	-h, --help, --man  This documentation

=item   --url The url of the service to check.

=back

=head1	AUTHORS

Thomas Brettin

=cut

