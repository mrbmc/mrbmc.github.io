#!/bin/zsh
echo "* * * * * * * * * * * * * * * * * * * * * * *";
SRC="$(dirname "$0")";
OUT="$(dirname "$0")/../www/";
echo "Building mrbmc website in $SRC > $OUT";
cd $SRC;

echo "* * * * * * * * * * * * * * * * * * * * * * *";
echo "LESS > CSS";
echo "--------------------";
echo "Compile screen.less";
lessc --source-map-inline --clean-css="--s1 --advanced --compatibility=ie8" $SRC/less/screen.less $OUT/css/screen.min.css
echo "Compile dependent less";
lessc --source-map-inline --clean-css="--s1 --advanced --compatibility=ie8" $SRC/less/print.less $OUT/css/print.min.css
lessc --source-map-inline --clean-css="--s1 --advanced --compatibility=ie8" $SRC/less/chart.less $OUT/css/chart.min.css


# echo "--------------------";
# echo "Compilng partials";
# handlebars -m lib/templates/footer.hbs lib/templates/header.hbs -f js/partials.compiled.js;
# echo "Attach partials to primary JS";
# cat js/partials.compiled.js >> $OUT/js/mrbmc.min.js;
# rm js/partials.compiled.js;


echo "* * * * * * * * * * * * * * * * * * * * * * *";
echo "PREPARE JS";
echo "--------------------";
echo "Minify common JS";
uglifyjs -m -c sequences=true,dead_code,conditionals,booleans,unused,if_return,join_vars \
	--source-map url=mrbmc.min.js.map \
	-o $OUT/js/mrbmc.min.js \
	$SRC/lib/js/mrbmc.js $SRC/lib/js/mixins.js $SRC/lib/js/file-management.js $SRC/lib/js/portfolio-data.js;



echo "--------------------";
echo "Static HTML";
node $SRC/lib/js/hb-compiler.js $SRC/lib/templates/home.hbs $OUT/index.html;
node $SRC/lib/js/hb-compiler.js $SRC/lib/templates/about.hbs $OUT/about.html;


echo "--------------------";
echo "Compilng templates for /blog";
handlebars $SRC/lib/templates/post_list.hbs $SRC/lib/templates/post_detail.hbs -f $SRC/lib/js/blog.compiled.js;
echo "Minify Blog JS";
uglifyjs -c sequences=true,dead_code,conditionals,booleans,unused,if_return,join_vars -o $OUT/js/blog.min.js --source-map url=blog.min.js.map \
$SRC/lib/js/blog.js $SRC/lib/js/blog.compiled.js
node $SRC/lib/js/hb-compiler.js $SRC/lib/templates/blog.hbs $SRC/blog/index.html


echo "--------------------";
echo "Compilng templates for /portfolio";
handlebars $SRC/lib/templates/project_detail.hbs $SRC/lib/templates/gallery.hbs -f $SRC/lib/js/portfolio.compiled.js;
#$SRC/lib/templates/project_list.hbs 
echo "Minify portfolio JS";
uglifyjs \
	-c sequences=true,dead_code,conditionals,booleans,unused,if_return,join_vars \
	-o $OUT/js/portfolio.min.js \
	--source-map url=portfolio.min.js.map \
	$SRC/lib/js/portfolio.js $SRC/lib/js/gallery.js $SRC/lib/js/portfolio.compiled.js;
node $SRC/lib/js/hb-compiler.js $SRC/lib/templates/portfolio.hbs $SRC/portfolio/index.html


echo "--------------------";
echo "Compliling GALLERY templates";
handlebars $SRC/lib/templates/gallery.hbs -f $SRC/lib/js/gallery.compiled.js;
echo "COMBINE GALLERY JS";
echo "Minify GALLERY JS";
uglifyjs -c sequences=true,dead_code,conditionals,booleans,unused,if_return,join_vars -o $OUT/js/photos.min.js --source-map url=photos.min.js.map \
$SRC/lib/js/photos.js $SRC/lib/js/gallery.js $SRC/lib/js/gallery.compiled.js;

echo "--------------------";
echo "Garbage Collection";
rm $SRC/lib/js/blog.compiled.js;
rm $SRC/lib/js/portfolio.compiled.js;
rm $SRC/lib/js/gallery.compiled.js;

echo "--------------------";
echo "Building BOIDS";
uglifyjs $SRC/lib/js/boids.js -c sequences=true,dead_code,conditionals,booleans,unused,if_return,join_vars -o $OUT/js/boids.min.js --source-map url=blog.min.js.map


echo "--------------------";
echo "Copy library dependencies";
cp $SRC/node_modules/handlebars/dist/handlebars.runtime.min.js $OUT/js
# cp ./node_modules/tumblr.js/lib/tumblr.js -m -o $OUT/js/tumblr.min.js


echo "* * * * * * * * * * * * * * * * * * * * * * *";
echo "Deploy Static Assets";
rsync -auv --include='*.html' --include='*.txt' --include='*.xml' --include='*.ico' --exclude="*" $SRC/ $OUT
rsync -auv $SRC/lib/fonts/ $OUT/css/fonts;
rsync -auv $SRC/img $OUT;
echo "Deploy Site Sections";
rsync -au --delete $SRC/blog $OUT;
rsync -au --delete $SRC/photos $OUT;
rsync -au --delete $SRC/portfolio $OUT;
echo "--------------------";
echo "updating runtime permissions";
chmod -Rf 755 $OUT;

# rm $OUT/.DS_Store $OUT/*/.DS_Store;

# sequences=true,dead_code,conditionals,booleans,unused,if_return,join_vars
#echo "* * * * * * * * * * * * * * * * * * * * * * *";
#echo "Backing up files to gDrive";
# rsync -auv --delete ~brianmcconnell/Sites/mrbmc/ ~brianmcconnell/Google\ Drive/My\ Drive/Sites/mrbmc;


#echo "* * * * * * * * * * * * * * * * * * * * * * *";
#echo "DEPLOY TO AWS";
#aws s3 sync $OUT s3://www.brianmcconnell.me --delete
# aws cloudfront  create-invalidation --distribution-id E1TNSK7JF24IAY --paths \
# "/img/*" "/css/*" "/js/*" \
# "/portfolio/*" \
# "/blog/*" \
# "/resume/*" \
# "/index.html" "/404.html" "/error.html" "/about.html" "/boids.html";

# echo "* * * * * * * * * * * * * * * * * * * * * * *";
# echo "DONE";

