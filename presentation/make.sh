#!/bin/sh

haml index.haml > index.html
sass style.scss style.css
coffee -c app.coffee
