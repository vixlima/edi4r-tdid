#!/usr/bin/env ruby
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

# Are there multiple DE of the same name in a CDE which
# do not form a sequence?
# Likewise, are there (C)DE in a segment with the same property?
#
def search_for_distant_duplicates( name_list, seg )
  (0...name_list.size-2).each do |i|
    left = name_list[i]
    next if name_list[i+1] == left
    name_list[i+1..-1].each do |right|
      puts "Distant duplicates found: #{left} in #{seg}/#{name_list.join(',')}" if left == right
    end
  end
end

class EDIFACT_2_Tests < Test::Unit::TestCase

  def test_messages
    puts "Testing all messages in all TDID diagrams - this may take a while."

    IO.foreach('dirlist') do |line|
      next if line =~ /^#/
      version, release, agency = line.chomp.split(/:/)  # e.g.: D, 96A, UN

      # SV4 from D.00A on required!
      ic = EDI::E::Interchange.new( :version=> (release =~ /^[0-7]/ ? 4 : 3) )

      msglist = {}
      EDI::Dir::Directory.flush_cache # or you'll run out of memory ...
      EDI::Diagram::Diagram.flush_cache

      params={:d0052=>version, :d0054=>release, :d0051=>agency,:is_iedi=>false}
      m_params = {:version=>version, :release=>release, :resp_agency=>agency}
      assert_nothing_raised {
        EDI::Dir::Directory.create('E', params).message_names.each do |name|
          msglist[$1]=true if name =~ /^([A-Z]{6}):/
        end
      }
      puts diag_key = [version, release, agency].join(':')
      msglist.keys.sort.each do |msgname|
        # puts "message #{msgname} in #{diag_key}:"
        params[:d0065] = m_params[:msg_type] = msgname
        diag = msg = nil 
        assert_nothing_raised {diag = EDI::Diagram::Diagram.create('E',params)}
        assert_nothing_raised {msg = ic.new_message( m_params )}
        assert_nothing_raised do
          diag.each do |node| 
            seg = msg.new_segment( node.name )
            names = seg.names
            search_for_distant_duplicates( names, seg.name )
#            seg.each do |cde|
#              next unless cde.is_a? EDI::CDE
#              search_for_distant_duplicates( cde.names, cde.name )
#            end
          end
        end
        print '.'; $stdout.sync
      end
      puts
    end
    puts "SV4 not used for testing yet!"
  end

  def test_diagrams_I_EDI
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

end
