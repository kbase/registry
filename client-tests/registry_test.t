use Config::Simple ('-lc'); # ignoring case, don't save to file.
use IO::Socket::INET;
use Test::More;

# set package variables

our $cfg = {};
if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) {
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG}) or
	die "could not load config file: $ENV{KB_DEPLOYMENT_CONFIG}, ",
		Config::Simple->error();
}
else {
    $cfg = new Config::Simple(syntax=>'ini') or
        die "could not create config object ",
		Config::Simple->error();
    $cfg->param('registry.mongodb-host', 'mongodb.kbase.us');
    $cfg->param('registry.mongodb-db', 'registry');
    $cfg->param('registry.mongodb-collection', 'test');
    $cfg->param('registry.service-host', '127.0.0.1');
    $cfg->param('registry.service-port', '7070');
}

# ping the running server as we need a running server to test the client against

print "\nchecking for running server on ",
	$cfg->param('registry.service-host'), ":",
	$cfg->param('registry.service-port'), "\n";

die "error $@" unless 
   $sock = IO::Socket::INET->new(PeerPort  => $cfg->param('registry.service-port'),
                                 PeerAddr  => $cfg->param('registry.service-host'),
                                 Proto     => tcp,
				);    

print "\nlooks good\n";

BEGIN {use_ok(Bio::KBase::ServiceRegistry::Client);};
can_ok('Bio::KBase::ServiceRegistry::Client', 'register_service');
can_ok('Bio::KBase::ServiceRegistry::Client', 'deregister_service');
can_ok('Bio::KBase::ServiceRegistry::Client', 'update_nginx');
can_ok('Bio::KBase::ServiceRegistry::Client', 'enumerate_services');
can_ok('Bio::KBase::ServiceRegistry::Client', 'enumerate_service_urls');
can_ok('Bio::KBase::ServiceRegistry::Client', 'get_service_specification');
can_ok('Bio::KBase::ServiceRegistry::Client', 'is_alive');
can_ok('Bio::KBase::ServiceRegistry::Client', 'get_expiration_interval');


done_testing();

