#! /bin/sh


usage="$(basename "$0") -- build bookdown book
		  -h show help and exit
		  -a upload book to aws"

amazon=false # check options
while getopts "ah" opt; do
    case $opt in
	h) printf "$usage\n"
	   exit
	   ;;
	a) amazon=true
	   ;;
    esac
done

# get most recent Rmd file
RMDFILE="$(ls -Art *.Rmd | tail -n 1)"
BASENAME=(${RMDFILE//.Rmd/})

# generate/update the markdown
Rscript -e "bookdown::preview_chapter('${RMDFILE}')"

# copy the markdown file and associated files over to other dir
cp _book/${BASENAME}.md ~/Dropbox/notebook_render/${BASENAME}.Rmd
cp -r _bookdown_files/${BASENAME}_files ~/Dropbox/notebook_render/_bookdown_files

# build book
cd ./render_dir/
Rscript -e "bookdown::render_book('index.Rmd')"
open -a "Safari" _book/index.html

# upload to aws
if [ $amazon == true ]; then
    aws s3 sync _book/ s3://[bucket name] # set bucket name
fi
