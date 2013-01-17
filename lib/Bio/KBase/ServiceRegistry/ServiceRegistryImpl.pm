package Bio::KBase::ServiceRegistry::ServiceRegistryImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

ServiceRegistry

=head1 DESCRIPTION



=cut

#BEGIN_HEADER
use MongoDB;
use MongoDB::OID;
use Config::Simple;
use JSON -support_by_pp;
# set package variables
my $cfg = {};
if (defined $ENV{KB_DEPLOYMENT_CONFIG} && -e $ENV{KB_DEPLOYMENT_CONFIG}) {
	$cfg = new Config::Simple($ENV{KB_DEPLOYMENT_CONFIG});
}
else {
	$cfg->{'mongodb-host'} = 'mongodb.kbase.us';
}
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
	$self->{'conn'} = MongoDB::Connection->new(host => $cfg->{'mongodb-host'});
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

	# validate args
	defined $info->{'hostname'}     or die"service info did not contain a hostname";
	defined $info->{'service_name'} or die "service info did not contain a service_name";
	defined $info->{'port'}         or die "service info did not contain a port";
	defined $info->{'namespace'}      or die "service info did not contain a namespace";

	# convert service info to json doc
	my $json_text = to_json($info, {pretty=>1});
	print $json_text;

	# validate json doc


	# insert json doc into mongo db


	# update nginx config
	$self->update_nginx($info);

	# return service id
	$service_id=1;

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
$return is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string

</pre>

=end html

=begin text

$return is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string


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
    #END enumerate_services
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to enumerate_services:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'enumerate_services');
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

  $alive = $obj->is_alive($service_name, $namespace)

=over 4

=item Parameter and return types

=begin html

<pre>
$service_name is a string
$namespace is a string
$alive is an int

</pre>

=end html

=begin text

$service_name is a string
$namespace is a string
$alive is an int


=end text



=item Description

Is the service alive. The is_alive function will only verify that
the end-point can be reached over the WAN.

=back

=cut

sub is_alive
{
    my $self = shift;
    my($service_name, $namespace) = @_;

    my @_bad_arguments;
    (!ref($service_name)) or push(@_bad_arguments, "Invalid type for argument \"service_name\" (value was \"$service_name\")");
    (!ref($namespace)) or push(@_bad_arguments, "Invalid type for argument \"namespace\" (value was \"$namespace\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to is_alive:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'is_alive');
    }

    my $ctx = $Bio::KBase::ServiceRegistry::Service::CallContext;
    my($alive);
    #BEGIN is_alive
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

Information about a service such as it's name and it's 
namespace are captured in the ServiceInfo structure.
The keys and values in the structure are:
     service_name - holds a string that is the service name.
     namespace - holds a string that is an enumeration of the
                             different types of deployments, such as
                             prod, dev, test, etc.


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
