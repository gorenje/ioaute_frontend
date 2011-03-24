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
## ensure we always have the same order:
["cappuccino", "LPKit", "TNKit", "WyzihatKit"].each do |libname|
  libname = "Libraries/#{libname}"
  puts " ====> Building #{libname}"
  `cd #{libname} && jake debug && jake release`
  if $?.exitstatus > 0
    puts " !!!!! FAILED! to build #{libname}, exiting ..."
    exit 1
  end
end

puts "Applying Cappuccino Framework to project ..."
`export CAPP_BUILD=#{Dir.pwd}/Libraries/Cappuccino/Build && capp gen -f --force -l .`
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
