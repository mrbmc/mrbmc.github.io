const { src, dest, series } = require('gulp');
const sass = require('gulp-sass')(require('sass'));
const uglify = require('gulp-uglify');
const cleanCSS = require('gulp-clean-css'); // If you want CSS minification
const sourcemaps = require('gulp-sourcemaps');
const rsync = require('gulp-rsync');
const exec = require('child_process').exec;
const yargs = require('yargs');
const clean = require('gulp-clean');

// Command-line arguments parsing
const argv = yargs.argv;

// Define paths
const paths = {
  js: [
    'src/_js/mrbmc.js'
    ,'src/_js/gradient.js'
    ,'src/_js/photos.js'
    ,'src/_js/portfolio.js'
    ,'src/_js/gallery-inline.js'
    ,'src/_js/boids.js'
  ],
  backups: [
    'backup/1999/**/*',
    'backup/2000/**/*',
    'backup/2001/**/*',
    'backup/2002/**/*',
    'backup/2015/**/*',
    'backup/2022/**/*',
    'backup/2023/www/**/*'
  ],
  css: [
    'src/_scss/**/!(_*).scss'
  ],
  assets: [
    'src/images/**/*',
    'src/_fonts/PPNeueMontreal*'
  ],
  garbage: [
    // `${__dirname}/www/*/node_modules/**`,
    // `${__dirname}/www/metrics/**`,
    `${__dirname}/www/**/.DS_Store`
  ],
  html: ['src/**/*.md', 'src/**/*.njk'] // Eleventy source files (assuming Markdown or Nunjucks)
};


// Compile and minify JavaScript
function buildJS() {
  const log = argv.verbose ? console.log : () => {};
  return src(paths.js)
    .pipe(uglify())
    .on('data', file => log(`Uglified ${file.path}`))
    .pipe(dest('www/js'));
}

// Compile SCSS to CSS
function compileCSS() {
  const log = argv.verbose ? console.log : () => {};
  return src(paths.css)
    .pipe(sourcemaps.init())
    .pipe(sass().on('error', sass.logError))
    .pipe(cleanCSS()) // CSS minification
    .pipe(sourcemaps.write())
    .on('data', file => log(`Minified ${file.path}`))
    .pipe(dest('www/css'));
}

// Build HTML with Eleventy
function buildHTML() {
  const log = argv.verbose ? console.log : () => {};
  return exec('npx @11ty/eleventy')
    .on('data', data => log(data.toString()))
    .on('error', (err) => {
      console.error(`Error building HTML: ${err}`);
      process.exit(1);
    });
}

// Sync static assets (images)
function syncAssets() {
  const log = argv.verbose ? console.log : () => {};
  return src(paths.assets)
    .pipe(rsync({
      root: 'src',
      destination: 'www/images',
      exclude: ['portfolio/**','portfolio/','blog/**','blog/'],
      archive: true,
      silent: !argv.verbose
    }))
    .on('data', data => log(`Rsynced ${data}`))
    .on('end', () => console.log('Rsync completed'));
}

function syncBackups() {
  const log = argv.verbose ? console.log : () => {};
  return src(paths.backups)
    .pipe(rsync({
      root: 'backup',
      destination: 'www',
      archive: true,
      silent: !argv.verbose
    }))
    .on('data', data => log(`Rsynced ${data}`))
    .on('end', () => console.log('Rsync completed'));

}

// Clean up unnecessary files (garbage collection)
function cleanUp() {
  return src(paths.garbage).pipe(clean());
}

exports.quick = series(
  buildJS,
  compileCSS,
);

// Define default task
exports.full = series(
  buildJS,
  compileCSS,
  buildHTML,
  syncAssets,
  syncBackups,
  cleanUp
);
