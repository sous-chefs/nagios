#!/usr/bin/perl

use strict;
use Net::Nslookup;
use LWP::UserAgent;
use LWP::UserAgent::DNS::Hosts;
use Data::Dumper;

my $DEBUG = 0;

my $MONITORCONFIG = {
    'limelightagile' => {
        'active' => 1,
        'cname' => 'tealium-1.hs.llnwd.net.',
        'tests' => [
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.1.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=2592000',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.1.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=2592000',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.sync.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.sync.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tiqapp/utag.v.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=1800',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tiqapp/utag.v.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=1800',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.sub.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=3600',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.sub.js',
                'validate' => {
                    'content-type' => 'application/javascript',
                    'cache-control' => 'max-age=3600',
                    'content-encoding' => 'gzip'
                }
            }
        ]
    },
    'akamai' => {
        'active' => 1,
        'cname' => 'tags.tiqcdn.com.edgekey.net.',
        'tests' => [
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.1.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=2592000',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.1.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=2592000',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.sync.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.sync.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tiqapp/utag.v.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=1800',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tiqapp/utag.v.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=1800',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.sub.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=3600',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.sub.js',
                'validate' => {
                    'content-type' => 'application/x-javascript',
                    'cache-control' => 'max-age=3600',
                    'content-encoding' => 'gzip'
                }
            }
        ]
    },
    'edgecast' => {
        'active' => 0,
        'cname' => 'tags.wac.8194.edgecastcdn.net.',
        'tests' => [
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=300',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.1.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=2592000',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.1.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=2592000',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.sync.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=300'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.sync.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=300'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tiqapp/utag.v.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=1800'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tiqapp/utag.v.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=1800'
                }
            },
            {
                'active' => 1,
                'url' => 'http://tags.tiqcdn.com/utag/tealium/main/prod/utag.sub.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=3600',
                    'content-encoding' => 'gzip'
                }
            },
            {
                'active' => 1,
                'url' => 'https://tags.tiqcdn.com/utag/tealium/main/prod/utag.sub.js',
                'validate' => {
                    'content-type' => 'text/javascript',
                    'cache-control' => 'max-age=3600',
                    'content-encoding' => 'gzip'
                }
            }
        ]
    }
};

my @result;

for my $key(keys %$MONITORCONFIG){
    if ($MONITORCONFIG->{$key}->{'active'}) {
        debug("MONITORING: $key");
        my $dns = nslookup(host => $MONITORCONFIG->{$key}->{'cname'}, type => "A");

        LWP::UserAgent::DNS::Hosts->register_host('tags.tiqcdn.com' => $dns);
        LWP::UserAgent::DNS::Hosts->enable_override;
        
#        my $ua  = LWP::UserAgent->new;
        my $ua  = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });
        $ua->default_header('Accept-Encoding' => 'gzip,deflate,sdch');

        my @tests = @{$MONITORCONFIG->{$key}->{'tests'}};
        for my $test(@tests){
            if($test->{'active'}){
                debug("URL: $test->{'url'}");
                my $res = $ua->get($test->{'url'});
                for my $v(keys %{$test->{'validate'}}){
                    debug("  VALIDATE: $res->{'_headers'}->{$v}");
                    if($res->{'_headers'}->{$v} ne $test->{'validate'}->{$v}) {
                        debug("  RESULT: { status: fail, cdn: $key, url: $test->{'url'}, validate-key: $v, validate-value: $test->{'validate'}->{$v}, validate-actual: $res->{'_headers'}->{$v} }");
                        push @result, "{ status: fail, cdn: $key, url: $test->{'url'}, validate-key: $v, validate-value: $test->{'validate'}->{$v}, validate-actual: $res->{'_headers'}->{$v} }";
                    }else{
                        debug("  RESULT: { status: pass, cdn: $key, url: $test->{'url'}, validate-key: $v, validate-value: $test->{'validate'}->{$v}, validate-actual: $res->{'_headers'}->{$v} }");
                    }
                }
            }
            debug();
        }        
    }
}


if (!@result) {
    print "OK - (0)\n";
    exit 0;
}else{
    for my $r(@result){
        print "CRITICAL - $r\n";
    }
    exit 2;
}


sub debug{
    my($msg) = @_;
    if ($DEBUG) {
        print "$msg\n";
    }
    
}
