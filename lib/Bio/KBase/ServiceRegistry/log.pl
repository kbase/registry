#!/usr/bin/perl

# set up logging
use Log::Message::Simple qw(msg error debug);
local $Log::Message::Simple::MSG_FH = \*STDERR;
local $Log::Message::Simple::ERROR_FH = \*STDERR;
local $Log::Message::Simple::DEBUG_FH = \*STDERR;
our $verbose = 1;

# Logging Events	Symbol	Type
# METHOD_INVOKED	"MI"	info
# SERVER_INSTANCIATED	"SI"	info
# METHOD_EXECUTE_TIME	"ME"	info

msg("SI", $verbose);
error("ABORT", $verbose);
debug("some debug", $verbose);

