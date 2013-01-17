module ServiceRegistry {

    /* TYPE DECLARATIONS */

	/* Information about a service such as it's name and it's 
	   namespace are captured in the ServiceInfo structure.
	   The keys and values in the structure are:
		service_name - holds a string that is the service name.
		namespace - holds a string that is an enumeration of the
					different types of deployments, such as
					prod, dev, test, etc.
	*/
	typedef structure {
		string service_name;
		string namespace;
		string hostname;
		int port;
		list<string> ip_allows;
	} ServiceInfo;




    /* FUNCTION DECLARATIONS */

    /*  Register a service. Takes a service struct, and returns the
        service id that is assigned to the newly registered service.
        If the registration of a service is unsuccessful, either an
        error is thrown, or zero is returned.

	The side effect of the register_service call (either directly
	or via an agent on the frontend machine(s)) would be to create
	the nginx configuration stanza that maps api.kbase.us/name/namespace
	to the registered URL. See the update_nginx() function.
    */
    funcdef register_service(ServiceInfo info) returns (int service_id) authentication required;
    
    /* Deregister (delete) an existing service. Takes a service struct,
       and returns 1 if successfully deregistered, returns 0 if failed due
       to authentication issues or on input validation errors.  The namespace
       of the service to be deregistered must be specified in the input
       argument.
    */
    funcdef deregister_service(ServiceInfo info) returns (int success) authentication required;
    
    /* Update the nginx conf file. This function should be considered
	   private in so far as it would only be called from the 
	   register_service and deregister_service.
    */
	funcdef update_nginx(ServiceInfo info) returns (int success) authentication required;

	/* Provide a list of available services. The enumerate_services
	   simply returns the entire set of services that are available.
	*/
	funcdef enumerate_services() returns (mapping<string service_name, list<string> namespaces>);

	/* Get the interface description document for the service. The
       get_service_specification returns a string that represents the
       interface specification for the given service.
	*/
	funcdef get_service_specification(string service_name, string namespace) returns (string specification);



	/* These methods deal with service availability. */

	/* Is the service alive. The is_alive function will only verify that
	   the end-point can be reached over the WAN.
	*/
	funcdef is_alive(string service_name, string namespace) returns (int alive) authentication optional;


	/*  Get the seconds remaining until the service registration expires.

	*/
	funcdef get_expiration_interval(string service_name, string namespace) returns (int seconds_before_service_expiration);

};

