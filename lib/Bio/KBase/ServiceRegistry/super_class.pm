package super_class;
use Log::Log4perl qw(:easy);;
use Log::Log4perl::Appender::Screen;

# this should be initialized in a log.cfg file.
Log::Log4perl->easy_init($DEBUG);


sub new {
	get_logger()->info("standard log message: ", "info");
	bless {}, shift;
}

sub super_method {
	get_logger()->info("standard log message: ", "info");
	return shift;
}

1;
