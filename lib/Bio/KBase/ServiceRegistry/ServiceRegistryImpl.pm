package Bio::KBase::ServiceRegistry::ServiceRegistryImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

ServiceRegistry

=head1 DESCRIPTION

The service registry maintains a list of services and their
url endpoints. The design assumes deploy time registration
rather than runtime registration. The design assumes that
clients can construct the url using a defined standard for
service urls and therefor do not need to rely heavily on
registry lookups at runtime.

=cut

#BEGIN_HEADER
# set up logging
use Log::Message::Simple qw(msg error debug);
local $Log::Message::Simple::MSG_FH = \*STDERR;
local $Log::Message::Simple::ERROR_FH = \*STDERR;
local $Log::Message::Simple::DEBUG_FH = \*STDERR;
our $verbose = 1;

use MongoDB;
use MongoDB::OID;
use MongoDB::MongoClient;
use Config::Simple ('-lc'); # ignoring case, don't save to file.
use JSON -support_by_pp;
use Data::Dumper;
require LWP::UserAgent;


# set package variables
our $cfg = {};
if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) {
    $cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG}) or
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => Config::Simple->error(),
                                                         method_name => 'new');
}
else {
    $cfg = new Config::Simple(syntax=>'ini') or
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error => Config::Simple->error(),
                                                         method_name => 'new'); 
    $cfg->param('registry.mongodb-host', 'localhost');
    $cfg->param('registry.mongodb-db', 'registry');
    $cfg->param('registry.mongodb-collection', 'test');
    $cfg->param('registry.service-host', '127.0.0.1');
    $cfg->param('registry.service-port', '7070');
}
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    $self->{'client'} = 
	MongoDB::MongoClient->new({host => $cfg->param('registry.mongodb-host')});
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 register_service

  $service_id = $obj->register_service($info)

=over 4

=item Parameter and return types

=begin html

<pre>
$info is a ServiceInfo
$service_id is an int
ServiceInfo is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	namespace has a value which is a string
	hostname has a value which is a string
	port has a value which is an int
	ip_allows has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$info is a ServiceInfo
$service_id is an int
ServiceInfo is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	namespace has a value which is a string
	hostname has a value which is a string
	port has a value which is an int
	ip_allows has a value which is a reference to a list where each element is a string


=end text



=item Description

Register a service. Takes a service struct, and returns the
service id that is assigned to the newly registered service.
If the registration of a service is unsuccessful, either an
error is thrown, or zero is returned.

The side effect of the register_service call (either directly
or via an agent on the frontend machine(s)) would be to create
the nginx configuration stanza that maps api.kbase.us/name/namespace
to the registered URL. See the update_nginx() function.

=back

=cut

sub register_service
{
    my $self = shift;
    my($info) = @_;

    my @_bad_arguments;
    (ref($info) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"info\" (value was \"$info\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to register_service:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'register_service');
    }

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($service_id);
    #BEGIN register_service
        unless ($ctx->authenticated) {
                my $msg = "Unauthenticated user attempt to call update_nginx";
                Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                               method_name => 'update_nginx');
        }
    # validate args
    defined $info->{'hostname'}   or my $msg = "no hostname in service info";
    defined $info->{'service_name'} or my $msg = "no service_name in service info";
    defined $info->{'port'}       or my $msg = "no port in service info";
    defined $info->{'namespace'}  or my $msg =  "no namespace in service info";
    if (defined $msg and $msg) {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                            method_name => 'register_service');
    }

    # convert service info to json doc
    my $json_text = to_json($info, {pretty=>1});

    # validate json doc


    # get the mongo database collection
    my $database = $self->{client}->get_database($cfg->param('registry.mongodb-db'));
    my $collection = $database->get_collection($cfg->param('registry.mongodb-collection'));

    # check to make sure this service is not already registered
    my $object = $collection->find_one({hostname => $info->{hostname},
					service_name => $info->{service_name},
					port => $info->{port},
					namespace => $info->{namespace}},
	);
    if (defined $object and (keys %$object)) {
	# stuff this in an error string  if $object is defined
	my $msg  = "duplicate service found\n";
	$msg    .= "$_\t$object->{$_}\n" foreach (keys %$object);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                            method_name => 'register_service');
    }

    # insert json doc into mongo db
    my $oid  = $collection->insert($info, {safe => 1});

    # update nginx config
    $self->update_nginx($info);

    # return service id
    $service_id=$oid->to_string;

    #END register_service
    my @_bad_returns;
    (!ref($service_id)) or push(@_bad_returns, "Invalid type for return variable \"service_id\" (value was \"$service_id\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to register_service:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'register_service');
    }
    return($service_id);
}




=head2 deregister_service

  $success = $obj->deregister_service($info)

=over 4

=item Parameter and return types

=begin html

<pre>
$info is a ServiceInfo
$success is an int
ServiceInfo is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	namespace has a value which is a string
	hostname has a value which is a string
	port has a value which is an int
	ip_allows has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$info is a ServiceInfo
$success is an int
ServiceInfo is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	namespace has a value which is a string
	hostname has a value which is a string
	port has a value which is an int
	ip_allows has a value which is a reference to a list where each element is a string


=end text



=item Description

Deregister (delete) an existing service. Takes a service struct,
and returns 1 if successfully deregistered, returns 0 if failed due
to authentication issues or on input validation errors.  The namespace
of the service to be deregistered must be specified in the input
argument.

=back

=cut

sub deregister_service
{
    my $self = shift;
    my($info) = @_;

    my @_bad_arguments;
    (ref($info) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"info\" (value was \"$info\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to deregister_service:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'deregister_service');
    }

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($success);
    #BEGIN deregister_service
    unless ($ctx->authenticated) {
	my $msg = "Unauthenticated user attempt to call update_nginx";
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                               method_name => 'update_nginx');
        }
    # validate service info object
    
    # delete service document from collection
    my ($msg, $query);
    $query->{hostname} = $info->{hostname} or
	$msg =  "hostname not defined in service info";
    $query->{port} = $info->{port} or
	$msg =  "port not defined in service info";
    $query->{service_name} = $info->{service_name} or
	$msg =  "service_name not defined in service info";
    $query->{namespace} = $info->{namespace} or
	$msg =  "namespace not defined in service info";
    if($msg) {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                        method_name => 'deregister_service');
    }

    my $collection = $self->{client}->get_database($cfg->param('registry.mongodb-db'))->get_collection($cfg->param('registry.mongodb-collection'));
    $success = $collection->remove($query);


    #END deregister_service
    my @_bad_returns;
    (!ref($success)) or push(@_bad_returns, "Invalid type for return variable \"success\" (value was \"$success\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to deregister_service:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'deregister_service');
    }
    return($success);
}




=head2 update_nginx

  $success = $obj->update_nginx($info)

=over 4

=item Parameter and return types

=begin html

<pre>
$info is a ServiceInfo
$success is an int
ServiceInfo is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	namespace has a value which is a string
	hostname has a value which is a string
	port has a value which is an int
	ip_allows has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$info is a ServiceInfo
$success is an int
ServiceInfo is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	namespace has a value which is a string
	hostname has a value which is a string
	port has a value which is an int
	ip_allows has a value which is a reference to a list where each element is a string


=end text



=item Description

Update the nginx conf file. This function should be considered
private in so far as it would only be called from the 
register_service and deregister_service.

=back

=cut

sub update_nginx
{
    my $self = shift;
    my($info) = @_;

    my @_bad_arguments;
    (ref($info) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"info\" (value was \"$info\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to update_nginx:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'update_nginx');
    }

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($success);
    #BEGIN update_nginx
	unless ($ctx->authenticated) {
		my $msg = "Unauthenticated user attempt to call update_nginx";
		Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                                               method_name => 'update_nginx');
	}

	$success = 1;
    #END update_nginx
    my @_bad_returns;
    (!ref($success)) or push(@_bad_returns, "Invalid type for return variable \"success\" (value was \"$success\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to update_nginx:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'update_nginx');
    }
    return($success);
}




=head2 enumerate_services

  $return = $obj->enumerate_services()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a reference to a list where each element is a ServiceInfo
ServiceInfo is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	namespace has a value which is a string
	hostname has a value which is a string
	port has a value which is an int
	ip_allows has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$return is a reference to a list where each element is a ServiceInfo
ServiceInfo is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	namespace has a value which is a string
	hostname has a value which is a string
	port has a value which is an int
	ip_allows has a value which is a reference to a list where each element is a string


=end text



=item Description

Provide a list of available services. The enumerate_services
simply returns the entire set of services that are available.

=back

=cut

sub enumerate_services
{
    my $self = shift;

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($return);
    #BEGIN enumerate_services
	$return = [];
	my $collection = $self->{client}->get_database($cfg->param('registry.mongodb-db'))->get_collection($cfg->param('registry.mongodb-collection'));
	my $cursor  = $collection->find();
	while (my $object = $cursor->next()) {
	
		my $json_text = to_json($object, {convert_blessed => 1, pretty => 1});
		print $json_text;

		# construct a ServiceInfo structure
		my $info->{service_name} = $object->{service_name};
		$info->{namespace} = $object->{namespace};
		$info->{hostname}  = $object->{hostname};
		$info->{port}      = $object->{port};
		$info->{ip_allows} = $object->{ip_allows};
		
		push @$return, $info;
	}
	
    #END enumerate_services
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to enumerate_services:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'enumerate_services');
    }
    return($return);
}




=head2 enumerate_service_urls

  $return = $obj->enumerate_service_urls()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a reference to a list where each element is a string

</pre>

=end html

=begin text

$return is a reference to a list where each element is a string


=end text



=item Description

Provide a list of available service urls. The enumerate_service_urls
returns the entire set of service urls that are registered in
the registry. The url will contain the port.

=back

=cut

sub enumerate_service_urls
{
    my $self = shift;

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($return);
    #BEGIN enumerate_service_urls
	my $services = $self->enumerate_services();
	foreach my $info (@$services) {
		my $url = $info->{'hostname'} . ":" .
		   $info->{'port'}            . "/" .
		   $info->{'service_name'}   . "/" .
		   $info->{'namespace'};

		push @$return, $url;
	}
    #END enumerate_service_urls
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to enumerate_service_urls:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'enumerate_service_urls');
    }
    return($return);
}




=head2 get_service_specification

  $specification = $obj->get_service_specification($service_name, $namespace)

=over 4

=item Parameter and return types

=begin html

<pre>
$service_name is a string
$namespace is a string
$specification is a string

</pre>

=end html

=begin text

$service_name is a string
$namespace is a string
$specification is a string


=end text



=item Description

Get the interface description document for the service. The
get_service_specification returns a string that represents the
interface specification for the given service.

=back

=cut

sub get_service_specification
{
    my $self = shift;
    my($service_name, $namespace) = @_;

    my @_bad_arguments;
    (!ref($service_name)) or push(@_bad_arguments, "Invalid type for argument \"service_name\" (value was \"$service_name\")");
    (!ref($namespace)) or push(@_bad_arguments, "Invalid type for argument \"namespace\" (value was \"$namespace\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_service_specification:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_service_specification');
    }

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($specification);
    #BEGIN get_service_specification
    #END get_service_specification
    my @_bad_returns;
    (!ref($specification)) or push(@_bad_returns, "Invalid type for return variable \"specification\" (value was \"$specification\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_service_specification:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_service_specification');
    }
    return($specification);
}




=head2 is_alive

  $alive = $obj->is_alive($service_url)

=over 4

=item Parameter and return types

=begin html

<pre>
$service_url is a string
$alive is an int

</pre>

=end html

=begin text

$service_url is a string
$alive is an int


=end text



=item Description

Is the service alive. The is_alive function will only verify that
the end-point can be reached over the WAN. The service_url must include
the port (protocol://hosthame:port). If no protocol is provided, then
http is assumed.

=back

=cut

sub is_alive
{
    my $self = shift;
    my($service_url) = @_;

    my @_bad_arguments;
    (!ref($service_url)) or push(@_bad_arguments, "Invalid type for argument \"service_url\" (value was \"$service_url\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to is_alive:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'is_alive');
    }

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($alive);
    #BEGIN is_alive

	my $ua = LWP::UserAgent->new();
	$ua->timeout(10);
	my $response = $ua->get($service_url);
	my $rv = 0;
	
	# if we get to the server, is_success should not be true because a valid post payload
	# was not sent, so we assume the service is unreachable, I don't like this but works
	# for now.
	if ($response->is_success) {
		msg( "Response decoded content: " . $response->decoded_content . "\n", $verbose );
	}
	else {
		msg( "Response status: " . $response->status_line . "\n", $verbose);
		msg( "Response decoded content: " . $response->decoded_content . "\n", $verbose);
		my $ref;
		# we should get a valid json object back, it's a json rpc doc with the error
		# string set in the json payload. So for the service to be up, we need to
		# get back a valid json doc.
		eval { $ref = from_json($response->decoded_content) };
		if ($@) {
			msg( "Did not get parsable JSON when querying $service_url" );
		}
		else {
			$rv = 1 if defined $ref->{'version'} and defined $ref->{'error'};
			msg( Dumper $ref, $verbose);
		}
	}
	msg( "alive is set to $rv", $verbose );
	$alive = $rv;


    #END is_alive
    my @_bad_returns;
    (!ref($alive)) or push(@_bad_returns, "Invalid type for return variable \"alive\" (value was \"$alive\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to is_alive:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'is_alive');
    }
    return($alive);
}




=head2 get_expiration_interval

  $seconds_before_service_expiration = $obj->get_expiration_interval($service_name, $namespace)

=over 4

=item Parameter and return types

=begin html

<pre>
$service_name is a string
$namespace is a string
$seconds_before_service_expiration is an int

</pre>

=end html

=begin text

$service_name is a string
$namespace is a string
$seconds_before_service_expiration is an int


=end text



=item Description

Get the seconds remaining until the service registration expires.

=back

=cut

sub get_expiration_interval
{
    my $self = shift;
    my($service_name, $namespace) = @_;

    my @_bad_arguments;
    (!ref($service_name)) or push(@_bad_arguments, "Invalid type for argument \"service_name\" (value was \"$service_name\")");
    (!ref($namespace)) or push(@_bad_arguments, "Invalid type for argument \"namespace\" (value was \"$namespace\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_expiration_interval:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expiration_interval');
    }

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($seconds_before_service_expiration);
    #BEGIN get_expiration_interval
    #END get_expiration_interval
    my @_bad_returns;
    (!ref($seconds_before_service_expiration)) or push(@_bad_returns, "Invalid type for return variable \"seconds_before_service_expiration\" (value was \"$seconds_before_service_expiration\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_expiration_interval:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_expiration_interval');
    }
    return($seconds_before_service_expiration);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 ServiceInfo

=over 4



=item Description

Information about a service such as its name and its 
namespace are captured in the ServiceInfo structure.
The keys and values in the structure are:
     service_name - holds a string that is the service name.
     namespace - holds a string that is an enumeration of the
                             different types of deployments, such as
                             prod, dev, test, etc.
     hostname  - is the name of the host (or ip adress) that the 
                     service is running on.
     port      - is the port number that the service is listening on.
     ip_allows - is a list of IP addresses that should be allowed
                     to connect to this service. The default is all.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
service_name has a value which is a string
namespace has a value which is a string
hostname has a value which is a string
port has a value which is an int
ip_allows has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
service_name has a value which is a string
namespace has a value which is a string
hostname has a value which is a string
port has a value which is an int
ip_allows has a value which is a reference to a list where each element is a string


=end text

=back



=cut

1;
