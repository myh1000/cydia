#!/usr/bin/env perl

# Author: Patrick Muff <muff.pa@gmail.com>
# Purpose: Compiles a Cydia repository

use Digest::MD5;

sub md5sum {
    my $file = shift;
    my $digest = "";
    eval {
        open(FILE, $file) or die "Can't find file $file\n";
        my $ctx = Digest::MD5->new;
        $ctx->addfile(*FILE);
        $digest = $ctx->hexdigest;
        close(FILE);
    };
    if ($@) {
        print $@;
        return "";
    }
    return $digest;
}

# # build packages into deb/
# system("chmod 0755 uncompiled-packages/ -R");
#
# my $directory = 'uncompiled-packages/';
# opendir (DIR, $directory) or die $!;
# while (my $file = readdir(DIR)) {
# 	system("dpkg -b uncompiled-packages/".$file." deb/".$file.".deb");
# }
# closedir(DIR);

# scan the packages and write output to file Packages
system("dpkg-scanpackages debs/ /dev/null > Packages");

# bzip2 it to a new file
system("bzip2 -c9 Packages > Packages.bz2");

# gzip it
system("gzip -c9 Packages > Packages.gz");

# calculate the hashes and write to Release
system("cp 'Release Template' Release");
open(RLS, ">>Release");

@files = ("Packages", "Packages.gz", "Packages.bz2");
my $output = "";

foreach (@files) {
 	my $fname = $_;
	my $md5 =  md5sum($fname);
	my $size = -s $fname;
	$output = $output.$md5." ".$size." ".$fname."\n";
};

print RLS $output;
close(RLS);

# remove Release.gpg
system("rm Release.gpg");

# generate Release.gpg
system("gpg -abs -o Release.gpg Release");



exit 0;
