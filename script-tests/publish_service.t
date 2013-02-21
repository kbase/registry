use Test::More;
use Test::Trap;

# OK, the main question is how the test will find the scripts.
# We can assume that make deploy has been run, and the scripts
# have been wrapped in a shell script. We can also assume the 
# raw script file is located in plbin.

# During development, we can assume that make will deposit the
# script in $KB_TOP/plbin. This way, our test script will work
# as long as we're working in a kbase development container.

#$ENV{PLBIN} = "$ENV{KB_TOP}/plbin";
$ENV{PLBIN} = "/Users/brettin/local/dev/dev_container/modules/registry/scripts";
use lib "/Users/brettin/local/dev/dev_container/modules/registry/scripts";

use_ok( publish_service );
my @r = trap { $ENV{PLBIN}/publish_service->run("-h"); };
is($trap->exit,      0,  "Expecting publish_service to return 0");
is($trap->stderr,   '',  "Not expecting anything on STDERR");
ok($trap->stdout ne '',  "STDOUT is not an empty string");

done_testing;
