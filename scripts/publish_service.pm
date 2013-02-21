package publish_service;
__PACKAGE__->run(@ARGV ) unless caller();

# if run as a script, then @ARGV has the params
# if run as a module, then @_ has the params
sub run {
	shift @_ if $_[0] eq __PACKAGE__;

	use strict;
	use Bio::KBase::ServiceRegistry::Client;
	use Getopt::Long qw(GetOptionsFromArray);  # use @_ instead of @ARGV
	use Pod::Find qw(pod_where);		   # find pod in this module
	use Pod::Usage;

	my $man  = 0;
	my $help = 0;
	GetOptionsFromArray(\@_,
		'h'	=> \$help,
		'help'	=> \$help,
		'man'	=> \$man,
	) or pod2usage(0);
	pod2usage(-exitstatus => 0,
		  -output => \*STDOUT,
		  -verbose => 2,
		  -noperldoc => 1,
		  -input => pod_where({-inc => -1}, __PACKAGE__)
		 ) if $help or $man;

	# do a little validation on the parameters


	# main logic
	my $r = Bio::KBase::ServiceRegistry::Client->new();

}

=pod

=head1	NAME

publish_service

=head1	SYNOPSIS

=over

=item publish_service -h, --help, or --man

=back

=head1	DESCRIPTION

The publish service calles the publish_service method of a Bio::KBase::ServiceRegistry::Client object.

=head1	COMMAND-LINE OPTIONS

=over

=item	-h, --help, --man  This documentation

=back

=head1	AUTHORS

Thomas Brettin

=cut

1;

