# crapster
Crapster Version 1.0

Introduction
___________________________________________________________________
        Crapster is a Perl Script for identifying duplicates residind in a
        given directory.

        Uses sha1sum for computing checksum & much of the linux commands
        for operating.


Implementaion Details
___________________________________________________________________

        Operating System:       Linux
        Kernel Version:         2.6.21.5-smp
        Perl Version:           Version 5.8.8 (recommended V5.8.8 or above)


Usage
___________________________________________________________________
usage:./crapster.pl [-options]... [DIRECTORY] [file extension]

 -x --extension    -    Include file extension for search
 -f --omitfirst    -    Omits first file in the set of similar files
 -H --hardlinks    -    Display Hardlinks
 -d --delete       -    Deletes Duplicate files, except the first file in the set
 -i --idelete      -    Prompt before deleting, doesn't delete the first file
 -h --help         -    Display this help and Exit
 -v --version      -    Display Crapster Version

for every matched set as a default Crapster would display the checksum & size
as defaults. This info would also act as a differentiator between matched sets.

Options to be watched out:
        '-f' option can't be used as a multiple options with options '-H', '-d', '-i'.
        since '-f' omits the first file info of the matched file sets, this would lesser
        the info of the other option outputs.

        Care should be taken while using '-d' options since it deletes all the matched
        files forcefully in the set except the first matched one!. For smaller matched
        sets or deleting the matched files i would suggest to use '-i' to delete files
        since it prompts before it delets any file.

Colors on Output:
        Crapster shows output with different colors, these are only to analyse
        the output bit easier. Below are the meaning of different colors used.

        Bold white:     Directory name for which duplicates are checked
        Yellow:         Checksum
        Green:          File size
        Red:            Deleted files or Tentative files


TODO
_____________________________

* Improve Coding standards.
* Usage of getopt functions for much ease on future addition of options.


Bugs
_____________________________

Below are some known issues/bugs since Crapster Version 1.0
If found anymore issues please do feel free to contact me on sujaybiz@gmail.com

DATED           AUTHOR          STATUS          ISSUE
___________________________________________________________________
10-02-2009      -self-          Temporary fix   usage of wild character '*' for all files
                                                Only * would choose the first file in the dir
                                                as file extension
                                                fix: try \* or "*" rather than * alone.

19-02-2009      -self-          Not solved      Unpredictable when tested /proc dir as argument.


Contact Information
___________________________________________________________________
email: sujaybiz@gmail.com


Legal Information
___________________________________________________________________

-NIL-
