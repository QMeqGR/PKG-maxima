#!/bin/bash

# defaults
debug=0;
help=0;

# packname=$(cat ../CONFIG | gawk -F'=' '($1=="package-name"){print $2}')
# get package name
n=$(ls *.texi | wc -l | awk '{print $1}');
if [ $n -gt 1 ]; then
    echo "Found more than one .texi file. There should be only one PKG.texi file."
    if [ -e regen.texi ]; then
	echo "Remove the regen.texi file before running create_docs.sh."
    fi
    exit
else
    texifile=$(ls *.texi);
    packname=${texifile%%.texi}
    echo "Using packname= "$packname;
fi

MAXIMA_ROOT=$(cat ../CONFIG | gawk -F'=' '($1=="max_src"){print $2}')
buildindex=$MAXIMA_ROOT/doc/info/build_index.pl

###############################################
declare SWITCH
while getopts "dhm:" SWITCH; do
    case $SWITCH in
	d) debug=1 ;;
	h) help=1 ;;
	m) maxima_impl=$OPTARG; useCONFIG=0 ;;
    esac
done

if [ $# -eq 0 ] || [ $help -eq 1 ]; then
    echo
    echo "#######################"
    echo "#   create_docs.sh    #"
    echo "#######################"
    echo
    echo "use: create_docs.sh  [options]"
    echo "     (options with a * require an argument)"
    echo
    echo "    -d --- debug (leaves temp files, default is OFF)"
    echo "    -h --- help (show this help)"
    echo "    -m -*- specify maxima implementation, e.g. /path/to/maxima"
    echo
    exit
fi


echo "### Running makeinfo..."
makeinfo $packname.texi;
echo 
echo "### Running makeinfo --pdf ..."
makeinfo --pdf $packname.texi;
echo
echo "### Running makeinfo --html ..".
makeinfo --split=chapter --no-node-files --html \
	 -c OUTPUT_ENCODING_NAME=UTF-8 -e 10000 $packname.texi;
echo
echo "### Running makeinfo --plaintext ..."
makeinfo --plaintext $packname.texi > ../README.txt;
echo
echo "### Building .info index file..."
# build the .info index
$buildindex $packname.info > $packname-index.lisp;

echo
# build the html index
echo "### Building .info html index file..."
maxima --no-init --no-verify-html-index  \
       --preload=$MAXIMA_ROOT/doc/info/build-html-index.lisp \
       --batch-string='build_and_dump_html_index("./'"${packname}"'_html/*.html", output_file="package-index-html.lisp",truenamep=true);';

if [ -f "package-index-html.lisp" ]; then
    echo
    echo "### Creation of HTML docs successful."
    mv -f package-index-html.lisp $packname-index-html.lisp;
else
    echo "### Warning: no maxima-index-html.lisp was created for html docs."
fi


# clean up temporary files from pdf creation
if [ $debug -eq 0 ]; then
    echo
    echo "### Cleaning up..."
    rm $packname.aux $packname.fn $packname.fns $packname.log $packname.toc \
       $packname.vr $packname.vrs build-html-index.log 
fi

####################################################
## Create test suite from examples in $packname.texi
echo
echo "#### creating examples.txt and the rtest file."
echo "display2d:false$" > examples.txt
echo "load($packname)\$" >> examples.txt
cat $packname.texi | grep "(%i" | \
    gawk '(NF>1){for(i=2;i<NF+1;i++){printf("%s",$i)};printf("\n")}' \
	 >> examples.txt;

echo
echo "#### Running maxima on tests..."
maxima -q -b examples.txt > rtest.tmp.out;

echo
echo "#### Constructing rtest file... the rtest file must be edited"
cat rtest.tmp.out | gawk '($1~/%i/){for(i=2;i<NF+1;i++){printf("%s",$i)};printf(";\n");}($1~/%o/){for(i=2;i<NF+1;i++){printf("%s ",$i)};printf("$\n\n");}' > ../rtest_$packname.mac;


