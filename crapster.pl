#!/usr/bin/perl
##file: 	crapster.pl
##Objective:	To find similar files in a given dir
##arguments:	Dir name to search duplicates for
##usage:	./crapster [-options] [DIRECTORY] [file extension]\n
##perl version:	V5.8.8

use Cwd;
use Switch;

use Term::ANSIColor;
use Term::ANSIColor qw(:constants);

our $dir, $opt, $filext;

## Sub Routine for help
sub help_tab
{
	print "usage:./crapster [-options]... [DIRECTORY] [file extension]\n";
	print "Displays duplicates files in a given directory.\n\n";
	print " -x --extension		Include file extension for search\n";
	print " -f --omitfirst		Omit first file in the set of similar files\n";
	print " -H --hardlinks		Display Hardlinks\n";	
	print " -d --delete		Deletes Duplicate files, except the first file\n";
	print " -i --idelete		Prompt before deleting, doesn't delete the first file\n";
	print " -h --help		Display this help and Exit\n";	
	print " -v --version		Display Version\n\n";
	print 'Report bugs to <sujaybiz@gmail.com>.';
	print "\n";
	exit;
}

## Sub Routine to verify the arguments
sub check_arg
{
	my($pathname, $options, $ext)=@_;

	if($pathname)
	{
		my $chk = stat($pathname);
		if($chk eq '')
		{	
			print("Crapster: $pathname: $!\n");
			print "Try `./crapster --help' for more information.\n";
			exit;
		}
		if(!-d $pathname)
		{	print "Crapster: $pathname: is a file\n"; 
			print "Try `./crapster --help' for more information.\n";
			exit;	
		}
	}

	if($pathname eq 0 || $pathname eq '.' || $pathname eq '')	{	$dir = getcwd();	}
	else								{	$dir = $pathname;	}

	$opt 	= $options;

	if($ext eq '*' || $ext eq '.')	{	$filext = '';	}
	else				{	$filext = $ext;	}
	
	#print "DEBUG ==  $dir : $opt : $filext\n";	exit;
}

## Sub Routine to verify the options supplied.
sub verify_input_arg
{
	switch($ARGV[0])
	{
		case ['-x', '--extension']	{	&check_arg($ARGV[1], '-x', $ARGV[2]);	}
		case ['-f', '--omitfirst']	{	&check_arg($ARGV[1], '-f', 0);	}
		case ['-d', '--delete']		{	&check_arg($ARGV[1], '-d', 0);	}
		case ['-i', '--idelete']	{	&check_arg($ARGV[1], '-i', 0);	}
		case ['-H', '--hardlinks']	{	&check_arg($ARGV[1], '-H', 0);	}

		case ['-xf', '-fx']		{	&check_arg($ARGV[1], '-xf', $ARGV[2]);	}
		case ['-xd', '-dx']		{	&check_arg($ARGV[1], '-xd', $ARGV[2]);	}
		case ['-xi', '-ix']		{	&check_arg($ARGV[1], '-xi', $ARGV[2]);	}
		case ['-xH', '-Hx']		{	&check_arg($ARGV[1], '-xH', $ARGV[2]);	}
		case ['-dH', '-Hd']		{	&check_arg($ARGV[1], '-dH', 0);	}
		case ['-iH', '-Hi']		{	&check_arg($ARGV[1], '-iH', 0);	}
		
		case ['-xdH', '-xHd', '-dxH', '-dHx', '-Hxd', '-Hdx']
						{	&check_arg($ARGV[1], '-xdH', $ARGV[2]);	}
		case ['-xiH', '-xHi', '-ixH', '-iHx', '-Hxi', '-Hix']
						{	&check_arg($ARGV[1], '-xiH', $ARGV[2]);	}

		case ['-h', '--help']
						{	&help_tab;	}
		case ['-v', '--version']	{	print "Crapster Version 1.0\n";	 exit;	}
		else
						{	&check_arg($ARGV[0], 0, 0);	}
	}
}

## Sub Routine to list & sort the checksum of files (usage: sha1sum).
sub list_dirfiles
{
	$dir = quotemeta($dir);
	switch($opt)
	{
		case ['-x', '-xf', '-xd', '-xi', '-xH', '-xdf', '-xdH', '-xiH']
			{	system("find $dir -name \"*$filext\" -exec sha1sum {} \\; &> temp");	}
		else
			{	system("find $dir -name \"*\" -exec sha1sum {} \\; &> temp");	}
	}

	system("sort temp > temp1");
	unlink(temp);
}

## Sub Routine to print the size of the given file
sub print_size
{
	my(@file) = @_;
	my $unit;

	$file = join(' ', @file);	#mv filename in the array to scalar variable
	$file =~ s/\s+$//; 		#remove trailing white spaces
	$size = -s $file;		#gets the size of the file

	print "Size: [";
	
	if( $size >= 1073741824 ) 
	{	$size=($size / 1073741824);	$unit='GB';	} 
	elsif( $size >= 1048576 ) 
	{	$size=($size / 1048576 );	$unit='MB';	} 
	elsif( $size >= 1024 ) 
	{	$size=($size / 1024 );		$unit='KB';	} 
	elsif( $size >= 0 ) 
	{	$unit='B';					} 
	else 
	{	$size='0';	$unit='B';			}
	
	print GREEN;	
	printf "%5.2f %s", $size, $unit;	
	print RESET;	print "]\n\n";
}

## Sub Routine to print colors for type of files.
sub normal_print()
{
	my(@file) = @_;
	$file = join(' ', @file);       #mv filename in the array to scalar variable
	$file =~ s/\s+$//;              #remove trailing white spaces

	if(-l $file)
	{	print BLUE,"$file", RESET;	
		print " -> ";	
		$file = quotemeta($file);
		system("readlink $file");
	}	
	else
	{	
		if($opt eq '-i'||$opt eq '-xi'||$opt eq '-iH'||$opt eq '-xiH'||$opt eq 'idelete')
		{	print RED, "$file\n", RESET;	}
		else
		{	print"$file\n";			}
	}
}

## Sub Routine to check for similar files & display.
sub check_similarfiles
{
	my(@cur_sum, @pre_sum, @pre_sum1);

	open(FILE,"<",temp1);
       	while (my $line = <FILE>)
	{
		chop($line);
	        @cur_sum = split(/ /, $line);

	        my $val = substr $cur_sum[0], 0, 1;
	 	last if($val eq 's');		

	        if($cur_sum[0] eq $pre_sum[0])
	        {
			## To print the first Element
			if($pre_sum1[0] ne $pre_sum[0])
			{
				## To print Checksum
				print "Checksum: ";	print YELLOW,"$cur_sum[0]\n", RESET;

				## To print size
				&print_size(@cur_sum[2 .. 100]);

				## Omits the first result, DO NOTHING!
				if($opt eq '-f' || $opt eq '-xf') {}

				## Normal Print with no options
				else	
				{
					## To print Hardlinks
					if($opt eq '-H' || $opt eq '-xH' || $opt eq '-xdH' || $opt eq '-xiH')
					{
						print "Hardlinks: \n";
						my $file = join(' ', @pre_sum[2 .. 100]);
						$file =~ s/\s+$//; 
						$file = quotemeta($file);
	
						print GREEN;
						system("find $dir -samefile $file");
						print RESET;	print "\n";
					}
					&normal_print(@pre_sum[2 .. 100]);	
				}
			}
			## Below 3 lines to avoid white space problem in filenames
			my $file = join(' ', @cur_sum[2 .. 100]);
			$file =~ s/\s+$//; 
			$file = quotemeta($file);

			## To Force Delete all the duplicate files
			if($opt eq '-d'||$opt eq '-xd'||$opt eq '-dH'||$opt eq '-xdH'||$opt eq 'delete')
			{
				print RED, "@cur_sum[2 .. 100]\n", RESET;
				system("rm -rf $file");
			}
			## Prompts before deleting
			elsif($opt eq '-i'||$opt eq '-xi'||$opt eq '-iH'||$opt eq '-xiH'||$opt eq 'idelete')
			{
				&normal_print(@cur_sum[2 .. 100]);
				system("rm -i $file");
			}
			## Normal Print with no options
			else
			{	&normal_print(@cur_sum[2 .. 100]);	}
		}
		
		if(($pre_sum1[0] eq $pre_sum[0]) && ($pre_sum[0] ne $cur_sum[0]))
		{	print "\n";	}	
		
		@pre_sum1 = @pre_sum;
		@pre_sum = @cur_sum;
	}

	unlink(temp1);
	close(FILE);
}

##--------------------------------------------------------
## Main: Everything starts from here

##-----------------------
## Crapster (03 Feb 2009)
##_______________________

&verify_input_arg;
	print "Similar files in dir:";
	print BOLD WHITE,"$dir\n", RESET;
&list_dirfiles;
&check_similarfiles;
