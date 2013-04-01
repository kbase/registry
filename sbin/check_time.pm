package check_time;

__PACKAGE__->run(@ARGV ) unless caller();
sub run {
	shift @_ if $_[0] eq __PACKAGE__;

	use strict;
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
	return check_time(@_);
}

sub check_time {
    print "tab: ",$_[0], "\n";

    my ($cmin, $chour, $cdom, $cmon, $cdow) = split /\s+/, `date "+%M %H %d %m %u"`;
    print "cur: $cmin, $chour, $cdom, $cmon, $cdow\n";

    my ($CMIN, $CHOUR, $CDOM, $CMON, $CDOW) = (0, 0, 0, 0, 0);
    my ($min, $hour, $dom, $mon, $dow) = split /\s+/, $_[0];
    print "tab: $min, $hour, $dom, $mon, $dow\n";

    $cdow -=1; #fix the 0-6 vs 1-7 issue
    if ($cmin == $min or $min eq '*') {
	# match
	$CMIN = 1;
    }
    if ($chour == $hour or $hour eq '*') {
	# match
	$CHOUR = 1;
    }
    if ($cdom == $dom or $dom eq '*') {
	#match
	$CDOM = 1;
    }
    if ($cmon == $mon or $mon eq '*') {
	#match
	$CMON = 1;
    }
    if ($cdow == $dow or $dow eq '*') {
	# match
	$CDOW = 1;
    }
    print "mat: $CMIN, $CHOUR, $CDOM, $CMON, $CDOW\n";
    return 1 if ($CMIN && $CHOUR && $CDOM && $CMON && $CDOW);
}


=pod

=head1	NAME

check_time

=head1	SYNOPSIS

=over

=item command line interface

perl check_time.pm -h, --help, or --man
perl ./check_time.pm "* * 22 * *"

=item application programming interface

use check_time

check_time->run("* * 22 * *");

=back

=head1	DESCRIPTION

The publish service calles the [% kb_method_name %] method of a [% kb_client %] object.

=head1	COMMAND-LINE OPTIONS

=over

=item	-h, --help, --man  This documentation

=back

=head1	AUTHORS

[% kb_author %]

=cut


1;
