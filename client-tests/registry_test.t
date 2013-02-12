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


print "\nconnecting to service\n";


use Bio::KBase::ServiceRegistry::Client;
use Bio::KBase::AuthToken;
our $service_url = "http://localhost:7070";

# make sure we can get a token from the Auth client
ok( $at = Bio::KBase::AuthToken->new('user_id' => 'kbasetest', 'password' => '@Suite525'),
    "Acquiring kbasetest user token using username/password");
ok($at->validate(), "Validating token from kbasetest username/password");
$ENV{'KB_AUTH_TOKEN'} = $at->token;

ok(register_service1(), "registering a service");
ok(register_service2(), "registering a service");
ok("ARRAY" eq ref( enumerate_services1()), "enumerating services");
ok(0 < enumerate_services2(), "enumerating services");
ok(1 == enumerate_service_urls1(), "enumerating service urls");
ok(deregister_service1(), "deregistering a service");

done_testing;

sub deregister_service1 {

	$query = {
	   "service_name" => "registry",
	   "namespace" => "test",
	   "hostname" => "localhost",
	   "port" => 1097
	};

	$s = Bio::KBase::ServiceRegistry::Client->new($service_url);
	$rv = $s->deregister_service($query);
	return $rv;
}

sub enumerate_services1 {
	$s = Bio::KBase::ServiceRegistry::Client->new($service_url);
	$objs = $s->enumerate_services();
	return $objs;
}

sub enumerate_services2 {
	my $services;
	my $s = Bio::KBase::ServiceRegistry::Client->new($service_url);
	my $objs = $s->enumerate_services();
	foreach $info (@$objs) {
		print "\n";
		print "$_: $info->{$_}\n" foreach keys %$info;
		$services++;
	}
	return $services;
}

sub enumerate_service_urls1 {
	my $services;
	my $s = Bio::KBase::ServiceRegistry::Client->new($service_url);
	my $objs = $s->enumerate_service_urls();
	foreach $url (@$objs) {
		print $url, "\n";
		$services++;
	}
	return $services;
}

sub register_service1 {
	my $s = Bio::KBase::ServiceRegistry::Client->new($service_url);
	my $query = {
	   "service_name" => "registry",
	   "hostname" => "localhost",
	   "port" => 1097
	};
        # This should fail because namespace is not defined
	eval {
		$s->register_service($query);
	};
	if($@) {
		return 1;
	}
	return 0;
}
sub register_service2 {
	my $query = {
	   "service_name" => "registry",
	   "namespace" => "test",
	   "hostname" => "localhost",
	   "port" => 1097

	};
	my $s = Bio::KBase::ServiceRegistry::Client->new($service_url);
	eval {
		$s->register_service($query);
	};
	if($@) {
		print $@;
		return 0;
	}
	return 1;
}
