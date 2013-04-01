# get the list of service urls
# every 5 seconds
#   foreach url
#     get stats on url
#     compute current, mean, high and low
#   end forech url
#   clear the terminal
#   print stats
# next
use Statistics::Descriptive;
use Data::Dumper;
use POSIX;
use Term::Cap;
use Term::ANSIColor;

# use Devel::Size qw(size total_size);
# my $foo = {a => [1, 2, 3],
#            b => {a => [1, 3, 4]}
#       };
# my $total_size = total_size($foo);




# General terminal line I/O
my $termios = new POSIX::Termios;
$termios->getattr;

# Extract the entry of the terminal type
my $term = Term::Cap->Tgetent( { OSPEED => $termios->getospeed } );

open LOG, ">monitor_service.log";

while(<>) {
    chomp;
    next if /^\s+$/;
    next if /^#/;
    push @entries, $_;
}

while(1) { 
    my $entry;

    foreach $entry (@entries) {
	my($url, $data, @special_params) = split /\t+/, $entry;
	next unless $url;

	my $command = "curl -o /dev/null -s ";
	$command .= join (" ", @special_params) if @special_params;
	$command .= " -d '$data' " if defined $data and $data;
	$command .= " -w '%{time_total}-";
	$command .= "%{time_pretransfer}-";
	$command .= "%{time_starttransfer}-";
	$command .= "%{http_code}' ";
	$command .= $url;
	print LOG $command, "\n";
	
	$r = `$command`;
	if ($?) {
	    print "$command returned $?\n";
	    next;
	}

	my @d = split/\-/, $r;
	die "did not get full data set, ", join(", ", @d), "\n" unless @d == 4;	
	push @{$h->{$url}->{time_total}},          $d[0];
	push @{$h->{$url}->{time_pretransfer}},    $d[1];
	push @{$h->{$url}->{time_starttransfer}},  $d[2];
	push @{$h->{$url}->{http_code}},           $d[3];
	
    }

    $term->Tputs('cl', 1, *STDOUT);
    printf('%1$-52s %2$6s %3$6s %4$6s %5$6s %6$6s %7$6s %8$6s %9$6s',
	   "Service",
	   "Code",
	   "Pre",
           "Start",
	   "Total",
	   "Min",
	   "Max",
	   "Mean",
	   "Dev"
	);
	print "\n";
	printf('%1$-52s %2$6s %3$6s %4$6s %5$6s %6$6s %7$6s %8$6s %9$6s',
           "-------",
           "------",
           "------",
           "------",
           "------",
           "------",
           "------",
           "------",
           "------"
        );

    print "\n";

    foreach $entry (@entries) {

	my($url, $data) = split /\t+/, $entry;
	next unless $url;

	my $service = $1 if $url =~ /\/([\w\-_]+)\/*$/;
	$stat = Statistics::Descriptive::Sparse->new();
	$stat->add_data(@{$h->{$url}->{time_total}});

	if (abs($h->{$url}->{time_total}->[-1] - $stat->mean()) > 
	    1.5 * $stat->standard_deviation()) {
	    print color 'red';
	}

	printf ('%1$-52s %2$6s %3$6.3f %4$6.3f %5$6.3f %6$6.3f %7$6.3f %8$6.3f %9$6.3f', 
		$url,
		$h->{$url}->{http_code}->[-1],
		$h->{$url}->{time_pretransfer}->[-1],
		$h->{$url}->{time_starttransfer}->[-1],
		$h->{$url}->{time_total}->[-1], 
		$stat->min(), 
		$stat->max(),
		$stat->mean(),
		$stat->standard_deviation()
	    );
	print "\n";
	print color 'reset';
    }

 
    sleep 20;
}

# at a given time, flush the data structure to disk and clear it.
# this allows us to reset the standard deviation and mean as these
# will vary depending on the time of day.
sub reset_on_time {
    # if time has been reached, write the data structure to file
    # and clear it out
    if ($TIME) {
	print LOG Dumper $_[0];
	undef $_[0];
    }
}


	
