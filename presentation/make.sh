#!/bin/sh

haml index.haml > final/index.html
haml about.haml > final/about.html
sass style.scss final/style.css
coffee -c app.coffee
mv app.js final/app.js
