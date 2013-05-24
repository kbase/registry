# in :easy mode, messages go to STDERR
use Log::Log4perl qw(:easy);
use Log::Log4perl::Appender::Screen;

# this should be initialized in a log.cfg file.
Log::Log4perl->easy_init($DEBUG);

# this initializes from a cfg file and rechecks the
# cfg file every 120 seconds
Log::Log4perl->init_and_watch("log.cfg", 120);
my $logger = get_logger();

$message = "standard log message: ";
$logger->debug($message,"debug" );
$logger->info($message, "info");
$logger->warn($message, "warn");
$logger->error($message, "error");
$logger->fatal($message, "fatal");

use sub_class;
my $sub = sub_class->new();
$sub->super_method();
$sub->sub_method();
