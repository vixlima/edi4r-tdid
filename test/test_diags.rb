#!/usr/bin/env ruby
# -*- encoding: ISO-8859-1 -*-
#
# $Id: test_diags.rb,v 1.1 2006/03/28 16:31:10 werntges Exp werntges $
#
# Copyright (c) 2006, 2011 Heinz W. Werntges, HS RheinMain
# Licensed under the same terms as Ruby. No warranty provided

# Load path magic...
$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'main', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'

require 'edi4r'
require 'edi4r/edifact'
require 'edi4r-tdid'

class EDIFACT_Tests < Test::Unit::TestCase

=begin
  def test_interchange
    puts "Path is: " + ENV['EDI_NDB_PATH']
    ic = nil
    assert_nothing_raised {
      ic = EDI::E::Interchange.new({})

      msg = ic.new_message({:name=> 'ORDERS',
                            :version=> 'S', 
                            :release=> '93A', 
                            :resp_agency=> 'UN', 
                            # :d0057=> @subset, 
			   })
      seg = msg.new_segment('BGM')
      msg.add seg
      seg.d1004 = '220'
      p seg.names
      seg = msg.new_segment('DTM')
      msg.add seg
      seg.cC507.d2005 = '137'
      p seg.cC507.names
      seg = msg.new_segment('UNS')
      seg.d0081 = 'S'
      msg.add seg
      p seg.names
      ic.add msg

      print ic
      puts
    }
    assert_nothing_raised {
      ic = EDI::E::Interchange.new({:show_una => false})
      ic.write $stdout
      puts
    }
    assert_equal( '0.9.1', ic.version )
  end
=end

begin
  def test_Diagrams
    puts "Testing all TDID diagrams - this may take a while."
    IO.foreach('dirlist') do |line|
      next if line =~ /^#/
      version, release, agency = line.chomp.split(/:/)  # e.g.: D, 96A, UN

      msglist = {}
      EDI::Dir::Directory.flush_cache # or else you'll run out of memory ...
      EDI::Diagram::Diagram.flush_cache

      params = {:d0052=>version, :d0054=>release, :d0051=>agency, :is_iedi=>false}
      assert_nothing_raised {
        EDI::Dir::Directory.create('E', params).message_names.each do |name|
          msglist[$1]=true if name =~ /^([A-Z]{6}):/
        end
      }
      puts diag_key = [version, release, agency].join(':')
      msglist.keys.sort.each do |msgname|
#        puts "message #{msgname} in #{diag_key}:"
        params[:d0065] = msgname
        assert_nothing_raised {
          diag = EDI::Diagram::Diagram.create('E', params)
#          diag.each {|node| puts node.name}
        }
        print '.'; $stdout.sync
      end
      puts
    end
    puts "SV4 not used for testing yet!"
  end
end


=begin
  def test_Diagrams_I_EDI
    puts "Testing all I-EDI TDID diagrams - this may take a while."
    IO.foreach('dirlist_iedi') do |line|
      next if line =~ /^#/
      version, release, agency = line.chomp.split(/:/)  # e.g.: D, 96A, UN

      msglist = {}
      EDI::Dir::Directory.flush_cache # or else you'll run out of memory ...
      EDI::Diagram::Diagram.flush_cache

      params = {:d0052=>version, :d0054=>release, :d0051=>agency, :is_iedi=>true}
      assert_nothing_raised {
        EDI::Dir::Directory.create('E', params).message_names.each do |name|
          msglist[$1]=true if name =~ /^([A-Z]{6}):/
        end
      }
      puts diag_key = [version, release, agency].join(':')
      msglist.keys.sort.each do |msgname|
#        puts "message #{msgname} in #{diag_key}:"
        params[:d0065] = msgname
        assert_nothing_raised { EDI::Diagram::Diagram.create('E', params) }
        print '.'; $stdout.sync
      end
      puts
    end
    puts "SV4 not used for testing yet!"
  end
=end


=begin
# Testing the lower-level DirObjects is probably outdated
# since we are able to test whole Diagrams.

  def test_DirObjects
    puts "Path is: " + ENV['EDI_NDB_PATH']
    puts "Testing all TDIDs - this may take a while."
    IO.foreach('dirlist') do |line|
      next if line =~ /^#/
      version, release, agency = line.chomp.split(/:/)  # e.g.: D, 96A, UN

      msglist = {}
      EDI::Dir::DirObject.caching_off   # or else you'll run out of memory ...

      assert_nothing_raised {
        d = EDI::Dir::DirObject.create('E',
                                       :d0052=>version,
                                       :d0054=>release,
                                       :d0051=>agency)
        d.message_names.each {|name| msglist[$1]=true if name =~ /^([A-Z]{6}):/}
      }
      puts [version, release, agency].join(':')
      msglist.keys.each do |msgname|
        assert_nothing_raised {
          d = EDI::Dir::DirObject.create('E',
                                       :d0065=>msgname,
                                       :d0052=>version,
                                       :d0054=>release,
                                       :d0051=>agency)
          print '.'; $stdout.sync
#          puts msgname +" in #{dir[0]}:#{dir[1]}"
        }
      end
      puts
    end
    puts "I_EDI directories not tested yet!"
    puts "SV4 not used for testing yet!"
  end
=end
end
