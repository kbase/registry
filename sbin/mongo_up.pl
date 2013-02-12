#!/usr/bin/perl

if (@ARGV == 0 or $ARGV[0] eq '-h' or $SRGV[0] eq '--help') {
	print "mongo_up.pl start||stop\n";
	exit 0;
}
unless ($ARGV[0] eq "start" or $ARGV[0] eq "stop" ) {
	print "invalid arg\n";
	print "mongo_up.pl start||stop\n";
	exit 0;
}

mongo_up() if $ARGV[0] eq "start";
mongo_down() if $ARGV[0] eq "stop";

sub mongo_up {
  # if mnt exists, use it
  if(-e "/mnt") {
    unless (-e "/mnt/data") {
      mkdir "/mnt/data" or die "can not mkdir /mnt/data for mongo";
    }
    unless (-e "/mnt/data/db") {
      mkdir "/mnt/data/db" or die "cannot mkdir /mnt/data/db for mongo";
    }
    $dbpath="/mnt/data";
  }
  # otherwise use the root partition
  else {
    unless(-e "/data") {
      mkdir "/data" or die "can not mkdir data for mongo";
    }
    unless(-e "/data/db") {
      mkdir "/data/db" or die "can not mkdir for mongo";
    }
    $dbpath="/data/db"
  }
  # make sure dbfilepath is writable
  die "$dbpath is not writable" unless -w $dbpath;

  unless (system("$ENV{KB_RUNTIME}/bin/mongod",
          "--pidfilepath=/tmp/mongo.$$.pid",
          "--logpath=/tmp/mongo.$$.log",
          "--dbpath=$dbpath",
          "--fork") == 0 ) {
              die "could not start mongod: $!";
  }
}

sub mongo_down {
  my $pid = `cat /tmp/mongo.$$.pid`;
  chomp $pid;
  unless (system("kill",  "-9", "$pid") == 0 ) {
          die "could not stop mongod with pid=$pid";
  }
  unlink "/tmp/mongo.$$.pid";
  unlink "/tmp/mongo.$$.log";
}


1;
