#!/usr/bin/perl -w
#############################################
#       
#   check-log-fast
#	
#	replacement for check-log that 
#	should be much faster, as well 
# 	as having the option to report if 
#	a given string is NOT found.
#
#############################################

use English;
use Carp;
use strict;
#use Cwd;

my($author) = "Joseph M. Anderson";
my($version) = "Version 1.0";
my($reldate) = "March 2011";

my($homedir) = $ENV{HOME};
my(@errorStrings);
my($reverse) = 0;
my($exitStatus) = 0;
my($exitMsg);

#############################################
#  Name:  Debug
#  Desc:  Print out debug info
#############################################
sub Debug {
my($msg) = @_;
        print "DEBUG:$msg\n";
}

#############################################
#  Name:  ShowUsage
#  Desc:  Print out usage info
#############################################
sub ShowUsage {
my($usg) = <<USGMSG;
        Usage:  $PROGRAM_NAME
		-l		target log file
		-r		"0" (if false) or "1" (if true) reverse (report absense of string)
		-s		string(s)
USGMSG
        print "$usg\n";
}

#############################################
#  Name:  HandleFlags
#  Desc:  Process command-line options
#############################################

sub HandleFlags {
        #Debug("HandleFlags(@ARGV)");
        ShowUsage and die "Need Arguments: $!\n" unless defined(@ARGV);
        my(@strings);
        my($file);
        while ($#ARGV >=0){
                my($flag) = shift @ARGV;
                if ($flag =~ /-l/) {
                        $file = shift @ARGV;
                }
                if ($flag =~ /-r/) {
                        $reverse = shift @ARGV;
                }
                if ($flag =~ /-s/) {
                        while ($#ARGV >=0){
                                my($string) = shift @ARGV;
                                push(@strings,"$string");
                        }
                        push(@errorStrings,@strings);
                }
        }
        GetResults($file,@errorStrings);
}

#############################################
#  Name:  Main
#  Desc:  Program exec sequence
#############################################
sub Main {
        #Debug("Main()");
        #print "$PROGRAM_NAME, $author, $version, $reldate\n";
        HandleFlags();
}

#############################################
#  Name:  GetResults
#  Desc:  Execute program subroutines
#############################################
sub GetResults {
        my($logfile,@matches) = @_;
        #Debug("GetResults($logfile,@matches)");
        CheckStampDir();
        my(@results) = LogAction($logfile,@matches);
        my($lines) = scalar(@results);
		
        if ($#results <= 0) {
			if ($reverse == 1) {
				$exitStatus = 1;
				$exitMsg = "WARNING: String(s) \"@errorStrings\" not found";
			} else {
				$exitStatus = 0;
				$exitMsg = "OK: String(s) \"@errorStrings\" not found";
			}
        } else {
			my($instances) = $#results+1;
			if ($reverse == 1) {
				$exitStatus = 0;
				$exitMsg = "OK: $instances instances of string(s): \"@errorStrings\" were found.";
			} else {
				$exitStatus = 1;
				$exitMsg = "WARNING: $instances instances of string(s): \"@errorStrings\" were found.";
				#PrintArray(@results);    
			}
		}
}

##########################################################################################
#       Pattern Matching/Extraction
##########################################################################################

#############################################
#  Name:  FindStringMatches
#  Desc:  Find matches in file
#############################################
sub FindStringMatches {
        my($logfile,$startline,@matches) = @_;
        #Debug("FindStringMatches($logfile,$startline,@matches)");
        my($match) = MatchAny(@matches);
        my(@results);
        open(FILE,"$logfile");
        while (<FILE>) {
                chomp;
                # begin at line X
                next unless $. >= $startline;
				# change logic to report if found
				push(@results,$_) if &$match;
				#print "found: $_\n" if &$match;
        }
        close(FILE);
        return @results;
}

#############################################
#  Name:  MatchAny
#  Desc:  Match any of a set of given patterns
#############################################
sub MatchAny {
        my(@pattern) = @_;
        #Debug("MatchAny(@pattern)");
        BuildMatch('||',@pattern);
}

#############################################
#  Name:  BuildMatch
#  Desc:  Efficient matching of large pattern set
#############################################
sub BuildMatch {
        my($condition,@pattern) = @_;
        #Debug("BuildMatch($condition,@pattern)");
        my($expr) = join("$condition", map { "m/\\b\$pattern[$_]\\b/o" } 0..$#pattern);
        my($match_func) = eval "sub { $expr }";
        die if $@;
        return $match_func;
}

##########################################################################################
#       Log File Change Detection
##########################################################################################

#############################################
#  Name:  LogAction
#  Desc:  determine log status/action
#############################################
sub LogAction {
        my($logfile,@matches) = @_;
        #Debug("LogAction($logfile,@matches)");
        my($stampfile) = StampFileName($logfile);
        # if stampfile doesn't exist, must be new
        return FirstRunLog($logfile,$stampfile,@matches) unless (-e $stampfile);
        # if it does exist, must be old but..
        if (-e $stampfile) {
                my($loglines) = FileLines($logfile);
                my($stamplines) = ReadLogStamp("lines",$stampfile);
                # has it been rotated? Same as if new
                return FirstRunLog($logfile,$stampfile,@matches) if ($loglines < $stamplines);
                # been appended? Check only new lines
                return NextRunLog($logfile,$stampfile,@matches) if ($loglines > $stamplines);
                # not chaged? Print nochange message and exit
                return "No change in log" if ($loglines = $stamplines);
        }
}

#############################################
#  Name:  FirstRunLog
#  Desc:  parsing entire log
#############################################
sub FirstRunLog {
        my($logfile,$stampfile,@matches) = @_;
        #Debug("FirstRunLog($logfile,$stampfile,@matches)");
        my(@results) = FindStringMatches($logfile,0,@matches);
        # create time stamp with log info
        WriteLogStamp($logfile,$stampfile);
        return @results;
}

#############################################
#  Name:  NextRunLog
#  Desc:  parsing changes only
#############################################
sub NextRunLog {
        my($logfile,$stampfile,@matches) = @_;
        #Debug("NextRunLog($logfile,$stampfile,@matches)");
        my($startline) = ReadLogStamp("lines",$stampfile);
        my(@results) = FindStringMatches($logfile,$startline,@matches);
        # create time stamp with log info
        WriteLogStamp($logfile,$stampfile);
        return @results;
}

##########################################################################################
#       Run-Time Cache info
##########################################################################################

#############################################
#  Name:  StampFileName
#  Desc:  return name of stamp file
#############################################
sub StampFileName {
        my($logfile) = @_;
        #Debug("StampFileName($logfile)");
        chomp(my $basename = `basename $logfile`);
        my($stampdir) = "$homedir/cache";
        my($stampfile) = "$stampdir/$basename.stp";
        return $stampfile;
}

#############################################
#  Name:  CheckStampDir
#  Desc:  check stamp file dir existence
#############################################
sub CheckStampDir {
		my($stampdir) = "$homedir/cache";
		mkdir($stampdir,0755) unless -e $stampdir;
}

#############################################
#  Name:  WriteLogStamp
#  Desc:  record log info for next run
#############################################
sub WriteLogStamp {
        my($logfile,$stampfile) = @_;
        #Debug("LogToStamp($logfile,$stampfile)");
        my($ctime) = FileTime($logfile);
        my($fsize) = FileSize($logfile);
        my($lines) = FileLines($logfile);
        open(FILE,">$stampfile") or die "Can't write to $stampfile: $!";
        print FILE "$ctime|$fsize|$lines";
        close(FILE);
}

#############################################
#  Name:  ReadLogStamp
#  Desc:  read log info from stamp file
#############################################
sub ReadLogStamp {
        # char should be "change", "size", or "lines"
        my($char,$stampfile) = @_;
        #Debug("ReadLogStamp($char,$stampfile)");
        open(FILE,"$stampfile") or die "Can't read $char from $stampfile: $!";
        while (<FILE>) {
                my($ctime,$fsize,$lines) = split(/\|/,$_);
                return $ctime if ( $char =~ /change/);
                return $fsize if ( $char =~ /size/);
                return $lines if ( $char =~ /lines/);
        }
}

#############################################
#  Name:  FileTime
#  Desc:  read change time of log file
#############################################
sub FileTime {
        my($filename) = @_;
        my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
        return $ctime;
}

#############################################
#  Name:  FileSize
#  Desc:  read size of log file
#############################################
sub FileSize {
        my($filename) = @_;
        my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
        return $size;
}

#############################################
#  Name:  FileLines
#  Desc:  read # lines in log file
#############################################
sub FileLines {
        my($filename) = @_;
        my($lines) = 0;
        open(FILE,"$filename") or die "Can't count lines in $filename: $!";
        $lines++ while <FILE>;
        close(FILE);
        return $lines;
}

#############################################
#  Name:  PrintArray 
#  Desc:  Print Array Contents
#############################################
sub PrintArray {
	my(@array) = @_;
	#Debug("PrintArray($#array)");
	foreach my $item (@array) {
		printf "$item\n";
	}
}

Main;

printf "$exitMsg\n";
exit $exitStatus;
