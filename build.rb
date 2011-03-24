#!/usr/bin/ruby
#
# Author: Gerrit Riessen, gerrit.riessen@open-source-consultants.de
# Copyright (C) 2011 Gerrit Riessen
# This code is licensed under the GNU Public License.
# 
# $Id$

#
# Build the libraries and the editor.
#
require 'fileutils'
require 'optparse'

puts "Building Libraries ..."
Dir.glob("Libraries/*").each do |libname|
  puts " ====> Building #{libname}"
  `cd #{libname} && jake release && jake build`
  if $?.exitstatus > 0
    puts " !!!!! FAILED! to build #{libname}, exiting ..."
    exit 1
  end
end

puts "Applying Cappuccino Framework to project ..."
`export CAPP_BUILD=$(pwd)/Libraries/Cappuccino/Build && capp gen -f --force -l .`
if $?.exitstatus > 0
  puts " !!!!! FAILED! to link in the cappuccino framework"
  exit 1
end

puts "Building project ..."
`jake flatten`
if $?.exitstatus > 0
  puts " !!!!! FAILED! to build framework"
  exit 1
end
