use strict;
use Data::Dumper;
use Carp;

use Bio::KBase::ServiceRegistry::Client;
use Getopt::Long;
use Pod::Usage;

my $man  = 0;
my $help = 0;
GetOptions('h'              => \$help,
	   'help'           => \$help,
	   'man'            => \$man,
    ) or pod2usage(2);
pod2usage(-exitstatus => 0, -verbose => 2) if $help or $man;

my $r = Bio::KBase::ServiceRegistry::Client();
my $services = $r->enumerate_service_urls();
foreach my $service_url (@$services) {
  print $service_url, "\n";
}

=pod

=head1	NAME

enumerate_service_urls

=head1	SYNOPSIS

enumerate_service_urls
enumerate_service_urls --help

=head1	DESCRIPTION

The enumerate_service_urls prints out the list of registered service urls
as those urls appear in the service registry. Some consideration is needed
in considering a proxy and redirects if they exist.

=head1	COMMAND-LINE OPTIONS

=over

=item	-h, --help, --man  This documentation

=back

=head1	AUTHORS

Thomas Brettin

=cut

