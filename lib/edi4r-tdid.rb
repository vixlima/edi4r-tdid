#!/usr/bin/env ruby
#
# :main:README
# :title:edi4r-tdid
#
# UN/EDIFACT add-on module: UN/TDIDs - UN Trade Data Interchange directories
#
# == Synopsis
#
#  Prepend this gem's data directory to the global
#  searchpath for "normdatabases" in EDI_NDB_PATH
#
# == Usage
#
#   require_gem 'edi4r-tdid'
#
#
# == Description
#
#  The edi4r base gem comes with only a few samples of UN/EDIFACT
#  normdata. This add-on provides the full collection of
#  UN Trade Data Interchange Directories (TDIDs), including those
#  distributed with the base gem.
#
#  We put this gem's data directory in front of the searchpath,
#  because it is usually the most frequently used one.
#
# == Environment
#
#  EDI_NDB_PATH
#
# :include:../AuthorCopyright
#--
# $Id: edi4r-tdid.rb,v 1.1 2006/08/01 10:56:04 werntges Exp $
#

BEGIN {

  require 'pathname'
  require 'edi4r'

# 'realpath' fails on Windows platforms!
#  path_to_add = Pathname.new(__FILE__).dirname.parent.realpath + 'data'
  pdir = Pathname.new(__FILE__).dirname.parent
  path_to_add =  File.expand_path(pdir) + File::Separator + 'data'

  paths = (ENV['EDI_NDB_PATH'] || '').split(/#{File::PATH_SEPARATOR}/)
  unless paths.include? path_to_add
    paths.unshift path_to_add
    ENV['EDI_NDB_PATH'] = paths.join File::PATH_SEPARATOR
  end

}
