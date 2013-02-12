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
  unless (system("$ENV{KB_RUNTIME}/bin/mongod",
          "--pidfilepath=/tmp/mongo.$$.pid",
          "--logpath=/tmp/mongo.$$.log",
          "--dbpath=$dbpath",
          "--fork") == 0 ) {
              die "could not start mongod";
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
