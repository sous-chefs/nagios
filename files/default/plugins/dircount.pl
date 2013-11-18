#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  dircount.pl
#
#        USAGE:  ./dircount.pl  
#
#  DESCRIPTION:  Try to quickly count the number of files in the dire.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gautam Dey (gdey), gautam@tealium.com
#      COMPANY:  Tealium Inc.
#      VERSION:  1.0
#      CREATED:  10/29/2013 11:38:33
#     REVISION:  ---
#===============================================================================

use v5.12.0;
use warnings;

my $dir = $ARGV[0] // '.';
my $warnlevel = $ARGV[1] // 10_000;
my $critlevel = $ARGV[2] // 100_000;

opendir(my $dh, $dir) || die "Could not open $dir";
my ($t,$pt,$et,$rt) = (0,0,0,0);;
for (readdir($dh)) {
    next if /^\.\.?$/;
    $t++;
    $pt++ , next if /^.+\.processing$/;
    $et++ , next if /^.+\.error$/;
    $rt++;
}
closedir($dh);

# 0 means ok
# 2 critical 
# 1 warning
say "Total files:$t ; Total error files:$et ; Total regular files:$rt ; Total files being processed:$pt";
exit 2 if $t >= $critlevel;
exit 1 if $t >= $warnlevel;
exit 0;
