# .htaccess redirect validator #

This is a script for the processing of files containing lists of Apache 301 Redirect directives of the kind we use all the time. Because the order of these directives is critical in how they're processed, it's way too easy to accidentally wreck a site by putting a redirect in the wrong order in an .htaccess file. Problems like this can be really difficult to track down and can go undetected for a long time or forever.

This script processes the redirects in the order they're defined, and it detects and potentially corrects three common error conditions:

1) Duplicate rules: while these can be harmless, they can also cause problems if the different rules point to different destination URLs. The script warns when it finds duplicates and skips them, which emulates Apache's behavior of redirecting when it finds the first match.

2) Obscured rules: because Apache executes the first redirect it matches, it is possible to define a rule at the top of an .htaccess file that prevents subsequent rules from ever being matched. The script makes a note that it has found a rule that is obscured by a prior rule and outputs the list of rules at the end in a way that prevents this condition form occurring in the output.

3) Infinite loops: it is possible to rediredt /a to /b and then later redirect /b to /a. Because Apache will process the redurects on each request, including one triggered by a redirect, this will result in an infinte loop. (Well, not quite infinite, but Apache will give up and the request will fail with an error message.) This script will detect and reject rules that would cause one of the simple loops described in the example. More complicated errors of this kind are possible, but this script doesn't look for them.

## Usage ##

To use the script to just detect and report on error conditions in a list of redirects:

`./redirect-validator.pl input_filename > /dev/null`

To use the script to discard duplicates and infinite loops and output the list of rules in an order that prevents obscured rules, outputting warnings and errors to the screen but not to the output file:

`./redirect-validator.pl input_filename > output_filename`

To do the above and suppress all errors and warnings:

`./redirect-validator.pl input_filename > output_filename 2>/dev/null`

## Infile specifications ##

This script isn't set up to process .htaccess files. It just processes files that contain lists of redirect rules, one per line, that strictly match the following format:

`Redirect 301 /austin/chamber /chamber`

Blank lines and lines that begin with the '#' character are not processed. Warnings and errors are written to STDOUT and the ordered list of rules is written to STDOUT.
