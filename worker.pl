#!/usr/bin/perl 
use strict;
use warnings;

$| = 1;
my $timeout = 2;

sub read_msg_or_timeout {
  my ($fh) = @_;
  my $n;
  my $char = "";
  my $msg;

  eval {
    local $SIG{ALRM} = sub { die "alarm\n" };
    alarm $timeout;

    while (sysread($fh, $char, 1)) {
      if ($char eq ':') {
	sysread($fh, $msg, int($n));
	return $msg;
      } else {
	$n .= $char;
      }
    }

    alarm 0;
  };

  return "";
}

open(my $out, ">", "perl.out") || die $!;

while (1) {
  print "9:heartbeat";

  #print "9:unhandled";

  my $msg = read_msg_or_timeout(*STDIN);
  if ($msg eq "ping") {
    print $out "$msg\n";
  }
}

