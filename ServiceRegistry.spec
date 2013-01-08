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
	structure {
		string service_name;
		string namespace;
	} ServiceInfo;




    /* FUNCTION DECLARATIONS */

    /*  Register a service. Takes a service struct, and returns the
        service id that is assigned to the newly registered service.
        If the registration of a service is unsuccessful, either an
        error is thrown, or zero is returned.
    */
    funcdef register_service(string service_name, string namespace) returns (int service_id) authentication required;
    
    /* Deregister (delete) an existing service. Takes a service struct,
       and returns 1 if successfully deregistered, returns 0 if failed due
       to authentication issues or on input validation errors.  The namespace
       of the service to be deregistered must be specified in the input
       argument.
    */
    funcdef deregister_service(string service_name, string namespace) returns(int success) authentication required;
    
    /* Update the nginx conf file. This function should be considered
	   private in so far as it would only be called from the 
	   register_service and deregister_service.
    */
	funcdef update_nginx (string service_name, string namespace) returns(int success) authentication required;

	/* Provide a list of available services. The enumerate_services
	   simply returns the entire set of services that are available.
	*/
	funcdef enumerate_services() returns (mapping<ServiceName name, list<Namespace namespaces>>);

	/* Get the interface description document for the service. The
	   get_service_specification returns a string that represents the
	   interface specification for the given service.
	*/
	get_service_specification(string service_name, string namespace) returns (string specification);



	





    /* The first set of methods deal with service availability.

        The registry will enable a single call recursive is_alive that 
        checks all registered services.

        The registry will enable a single call recursive is_alive that 
        checks a given service version and all dependent services.

        is_alive will only verify that the end-point can be reached over
        the WAN.
	*/
	funcdef is_alive(list<ServiceId>) returns (mapping<ServiceId, Boolean b> alive) authentication optional;


	/*


	*/
	funcdef get_expiration_interval(string service_name, string namespace) returns(int seconds_before_service_expiration);




	/* The second set of methods deals with service reliability.

        The registry will support a single function call that returns
        the state of all services.

        The client can query the registry once per hour to ensure the
        list of service urls are up to date.

	*/






	/* The third set of functions deal with client lookups

        Return a list of available running services for the user to
        choose from.

        Return a data structure for URLs of running services that allows
        clients to refer to the service URL by name.

        The registry will support client side commands that fetch service urls.
	*/
        
        
        
        The registry will not be a single point of system failure.
    */


}

