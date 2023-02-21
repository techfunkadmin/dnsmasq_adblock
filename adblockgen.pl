#! /usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
$| = 1;
my $content = '';
my $function_code = '';
my $read_toggle = 0;
my @urls = ();
my @blocked_hosts = ();
my $blocked_hosts_path = '/etc/blocked_hosts';
my $DEBUG = 0;

if ($ARGV[0])
{
	if (lc($ARGV[0]) eq "debug")
	{
		$DEBUG = 1;
	}
}

if ( -f $blocked_hosts_path ) {
	print "blocked host exists, skipping creation\n";
	exit 0;
}


if (open(my $source_list_fh, '<', '/etc/block_source.list'))
{
	while (my $line = <$source_list_fh>)
	{
		chomp($line);
		next if $line =~ m|^#|;
		push(@urls, $line);
	}
}
else 
{
	print "no block list found\n";
}

echo(sprintf("Found %s ad-provider URLS:\n\n%s\n", scalar(@urls), join("\n", @urls)));

my $cr_length = 0;
foreach my $url (@urls)
{
	echo(sprintf("Scanning '%s'", $url));
	my @hosts_from_url = grep { $_ !~ m/^#/ } split("\n", `curl -L --max-time 4 -XGET --insecure '$url' 2> /dev/null | tee -a /tmp/hosts.list`);
	
	foreach my $host (@hosts_from_url)
	{
		chomp($host);
		if ($host =~ m|^[0-9]+\.[0-9]+\.|)
		{
			my @lineParts = split(" ", $host);
			$host = $lineParts[1];
		}
		next unless $host;
		if($host =~ m/\s?([^\.][a-zA-Z\.\-0-9]+\.\w+)/)
		{
			$host = $1;
			$host =~ s/^\s+//;
			unless ( grep { $_ eq $host } @blocked_hosts)
			{
				push @blocked_hosts, $host;
			}
			my $c = scalar(@blocked_hosts);
			if ($c % 10 == 0)
			{
				for (my $cr_print_counter = 0; $cr_print_counter <= $cr_length; $cr_print_counter++)
				{
					print "\015";
				}
				$cr_length = length($c) + 1;
				print $c;
			}
		}
	}
	print "\n";
}
print "\n";

echo(sprintf("Found %s domains", scalar(@blocked_hosts)));
echo('Writing blacklist "./blocked_hosts"');

open(my $blocked_hosts, '>', $blocked_hosts_path) or die('target file could not be opened');

foreach my $host (@blocked_hosts)
{
	print $blocked_hosts sprintf("127.0.0.1\t%s\n", $host);
}

echo('Done');

sub echo {
	print sprintf("%s\n", shift);
}
