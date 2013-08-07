#!/usr/bin/perl -w                                                                                                                                                                                                                          
use v5.14.0;
# libdatetime-format-builder-perl needed                                                                                                                                                                                                     
# libfile-readbackwards-perl needed                                                                                                                                                                                                          # chelmiki@gmail.com

use DateTime ();
use DateTime::Duration ();
use DateTime::Format::Strptime ();
use File::ReadBackwards;

my %m = map { state $i=1; $_ => $i++ } qw( jan feb mar apr may jun jul aug sep oct nov dec );

my $num_args = $#ARGV + 1;
if ($num_args != 3) {
    print "\nUsage: check_last_logs.pl pattern minutes log_file\n";
    exit;
}

my $search = $ARGV[0];
my $interval = $ARGV[1];
my $log_file = $ARGV[2];
my $time_zone = 'UTC';

my $now    = DateTime->now;
$now->set_time_zone($time_zone);

my $delta  = DateTime::Duration->new( minutes => $interval );
my $ddelta = $now->subtract_duration($delta);

my $LOGS = File::ReadBackwards->new($log_file) or
    die "can't read file: $!\n";

while (defined(my $line = $LOGS->readline) ) {
    $line =~/^(?<month>[A-Za-z]+)\s+(?<day>\d+)\s+(?<time>(?<hours>\d+):(?<min>\d+):(?<sec>\d+))\s+(?<msg>.*)$/;
    #my $parser = DateTime::Format::Strptime->new( pattern => '%B-%d %T' );
    my $date_str = "$+{month}-$+{day} $+{hours}:$+{min}:$+{sec}";
    #my $dt = $parser->parse_datetime( $date_str );
    my $dt = DateTime->new(
         month  => $m{lc($+{month})},
         day    => $+{day},
         year   => $now->year,
         hour   => $+{hours},
         minute => $+{min},
         second => $+{sec}
    );

    if (($dt > $ddelta)) {
        if ($line =~ m/$search/){
            #print "OK - There are \"$search\" in the last $interval minutes\n";
            print "OK - There has been a Chef run on this machine in the last $interval minutes\n";
            close(LOGS);
            exit 0;
        }
    }
    else{
        last;
    }
}
#print "WARN - There are no \"$search\" in the last $interval minutes\n";
print "WARN - There has not been a Chef run on this machine in the last $interval minutes\n";
close(LOGS);
exit 1;
