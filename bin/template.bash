#!/bin/bash

set -o nounset  # Fail when access undefined variable
set -o errexit  # Exit when a command fails

SCRIPT_FILE=${0};
VERBOSE=${VERBOSE:-};

source tputcolors.bash
#source optparse.bash;
source ~/work/optparse/optparse.bash

#optparse.define long=template-bash-help desc="Simple true / false (string)" variable=REMOVE_SOURCE_FILE value="true" default="false"

error() {
    local _msg="$@";
    (>&2 echo $red"${_msg}"$normal)
    exit 1;
}
debug() {
    local _msg="$@";
    if [ "$VERBOSE" == "true" ]; then echo "$_msg"; fi
}

# Create the requested WRAPPERFD, save it's output to FILE, and then redirect
# the SOURCEFD to the WRAPPERFD. MODE must be either 'a' for append (Default)
# or 'w' to overwrite.
#
# $1 FD to redirect. One of: 'stdout' or 1, 'stderr' or 2
# $2 FILE to send output
# $3 MODE Should be either 'a' for append, or 'w' to replace. Default is append
redirect_fd() {
    local _fd=${1};
    local _file=${2};
    local _method=${3:-a};

    # Validate method
    if [ "${_method,,}" != 'a' -a "${_method,,}" != 'w' ]; then
        error "redirect_output: method should be 'w' for overwrite, or 'a' \
        append. Unknown method specified";
    fi

    if [ ! -z "${_file}" -a "${_file}" != '-' ]; then
        touch "${_file}" || error "Could not open {$_file} for writing"
    fi

    # Validate FD name
    case "${_fd,,}" in
        stdout|1)
            if [ "${_file}" != '-' ]; then
                [ "${_method}" == 'a' ] && exec 3>>$_file || exec 3>$_file;
                exec 1>&3;
            else
               # If file is -, then restore descriptors
              exec 3<&-;
              exec 1>&0;
            fi
        ;;

        stderr|2)
            if [ "${_file}" != '-' ]; then
                [ "${_method}" == 'a' ] && exec 4>>$_file || exec 4>$_file;
                exec 2>&4;
            else
               # If file is -, then restore descriptors
              exec 4<&-;
              exec 2>&0;
            fi
        ;;
        *)
            error "Unknown FD specified: ${_fd}. Must be one of stdout, or stderr"
        ;;
    esac
}


#######################
# Progress bar from
# https://github.com/fearside/ProgressBar/
# Modified to show a custom message, use AWK to handle big numbers / floats
######################
function ProgressBar {
    # Process data
    _progress=$( awk "{ printf \"%0.2f\", (${1}*100/${2}*100)/100 }" <<< '');
    _done=$( awk "{ printf \"%0.2f\", ${_progress}*4/10 }" <<< '' );
    _left=$( awk "{ printf \"%0.0f\", 40-${_done} }" <<< '' );
    _msg="${3}";

    # Build progressbar string lengths
    _done=$(printf "%${_done}s")
    _left=$(printf "%${_left}s")

    # Build progressbar strings and print the ProgressBar line
    printf "\r${_msg} Progress : [${_done// /#}${_left// /-}] ${_progress}%%"
}

#######################################
# End of script
# Perl POD documentation block follows
#######################################
: <<=cut
=pod

=head1 NAME

   template.bash - Starting point for bash scripts with helper functions and default scripts

=head1 SYNOPSIS

    C<source template.bash>
	
=head1 DESCRIPTION
.
This is a basic boilerplate starting template for bash scripts.  
This enables the B<nounset> and B<errexit> bash options to fail when
undefined variables are accessed, or exit if a command returns a non-zero status. 
We also include the B<optparse.bash> library for command line argument parsing.
A few useful functions are also included (See METHODS).

=head2 METHODS

=over 12

=item C<error>

B<$@> The error message to display

Outputs an error message and calls C<exit 1>. This method never returns. 

=item C<debug>

B<$@> The debug message to display

Writes a debug message to stdout using C<echo>, 
but only if the global C<$VERBOSE> variable is set to C<"true"> (That a string equal to "true")

=back

=head1 OPTPARSE.BASH USAGE EXAMPLE

    #source optparse.bash;  # No need to source, it is included by template.bash
    optparse.define short=c long=country desc="Array of options" variable=country list="USA Canada Japan Brasil England"
    optparse.define short=r long=remove desc="Simple true / false (string)" variable=REMOVE_SOURCE_FILE value="true" default="false"
    optparse.define short=o long=output desc="Defined value with optional default" variable=OUTPUT_FILE value="" default="."
    source $(optparse.build);

    # Command line options are now held in the global variable defined by C<variable="NAME"]

=head1 DOC USAGE

Docs are embedded using Perl style "POD" (Plain Old Documentation). Docs can be genrated using the 
C<perldoc>, C<perl2html> or C<pod2man> tools.

=head2 DOC TOOLS

This example uses the C<pod2man> tools, which includes the following: 

=over 12

=item C<pod2html>

Convert POD documenation to HTML

    pod2html myscript.sh > myscript.html

=item C<pod2man>

Generate a man page from a POD document

    pod2man myscript.sh > /usr/local/share/man/man1/myscript.sh.1

=item C<pod2markdown>

Convert POD documentation to Markdown format

    pod2markdown myscript.sh > myscript.md

=item C<pod2text>

Output POD documentation as plaintext

    pod2text myscript.sh

=item C<pod2usage>

Output the USAGE section from a POD embedded document

    pod2usage myscript.sh

=back

=head2 DOC EXAMPLE

Embed your Perl POD documenation in a bash heredoc, right after a noop (null) command ":". 

- Start with : <<=cut
- Write your POD-formatted man page
- End with =cut, which has also been defined as the end of the shell Here-doc

    #!/bin/bash

    echo Shell script goes here

    : <<=cut
    =pod

    =head1 NAME

       myscript.sh - Example shell script with embedded POD documentation

    =head1 SYNOPSIS

        myscript.sh [OPTIONS] <file>

    =head1 DESCRIPTION

    This is a simple way to embed POD documentation into shell scripts.
    Support for B<bold>, U<underlined>, I<italic>, and C<code> blocks also works. 
    You may embed links using the L<link> format.

    =head1 SEE ALSO

    L<perlpod|pod::perlpod>, L<http://example.com>

    =head1 NOTES

    Any heading may be used

    =head1 AUTHOR

    Author Info

    =cut

=head2 SEE ALSO

L<Original idea|http://bahut.alma.ch/2007/08/embedding-documentation-in-shell-script_16.html>

=head1 SEE ALSO

L<optparse|https://github.com/nk412/optparse>

=head1 LICENSE

BSD licensed

=head1 AUTHOR

Erik Phillips
http://github.com/erikvip

=cut