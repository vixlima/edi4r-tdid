#!/usr/bin/env ruby
#
# Copyright (c) 2006, 2011 Heinz W. Werntges, HS RheinMain, Wiesbaden
# Licensed under the same terms as Ruby. No warranty provided

# Load path magic...
$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'main', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'

require 'edi4r'
require 'edi4r/edifact'
require 'edi4r-tdid'

class EDIFACT_Tests < Test::Unit::TestCase

  def test_Diagrams_EANCOM
    puts "Testing all EANCOM diagrams - this may take a while."
    IO.foreach('dirlist_eancom') do |line|
      next if line =~ /^#/
      version, release, agency, subset = line.chomp.split(/:/)  # e.g.: D, 96A, UN, EAN

      msglist = {}
      EDI::Dir::Directory.flush_cache # or else you'll run out of memory ...
      EDI::Diagram::Diagram.flush_cache

      params = {:d0052=>version, :d0054=>release, :d0051=>agency, :d0057=>subset, :is_iedi=>false}
      assert_nothing_raised {
        EDI::Dir::Directory.create('E', params).message_names.each do |name|
          msglist[$1]=true if name =~ /^([A-Z]{6}):/
        end
      }
      puts diag_key = [version, release, agency, subset].join(':')
      msglist.keys.sort.each do |msgname|
#        warn "message #{msgname} in #{diag_key}:"
        params[:d0065] = msgname
        assert_nothing_raised do
          begin
            diag = EDI::Diagram::Diagram.create('E', params)
#           diag.each {|node| puts node.name}
          rescue EDI::EDILookupError
#            warn "skipping message #{msgname} in #{diag_key}:"
          rescue
            warn "Failed for message #{msgname} in #{diag_key}:"
            raise
          end
        end
        print '.'; $stdout.sync
      end
      puts
    end
    puts "SV4 not used for testing yet!"
  end
end
