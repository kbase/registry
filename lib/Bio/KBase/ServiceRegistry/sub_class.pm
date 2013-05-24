package sub_class;
use Log::Log4perl qw(:easy);;
use Log::Log4perl::Appender::Screen;
use super_class;
use base qw(super_class);

sub new {
	get_logger()->info("standard log message: ", "info");
	bless {}, shift;
}

sub sub_method {
	get_logger()->info("standard log message: ", "info");
	return shift;
}

1
