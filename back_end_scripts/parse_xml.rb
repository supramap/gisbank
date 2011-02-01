#!/usr/local/bin/ruby
require 'hpricot'

xml_file = File.new(ARGV[0], "r")

node_array = [] #Array of all nodes
apomorphy_hash = {} #Map of apomorphy => array of nodes

#Parse the xml file to build the $apomorphy_hash and the $node_array
xml = Hpricot(xml_file)
(xml/"node").each do |node|
  #First add the node and its ancestor to the node_hash
  node_id = (node/"id").inner_html
  node_ancestor = ((node/"ancestors")/"ancestor")[0].attributes["id"]
  node_weight = (node/"weight").inner_html
  node_array << [node_id, node_ancestor, node_weight]

  #Next add all the apomorphies to the apomorphy_hash
  ((node/"transformations")/"transformation").each do |trans|
    apomorphy_name = trans.attributes["id"]
    if apomorphy_hash[apomorphy_name].nil?
      apomorphy_hash[apomorphy_name] = [node_id]
    else
      apomorphy_hash[apomorphy_name] << node_id
    end
  end
end

#Print the output
node_array.each { |node| print "#{node[0]},#{node[1]},#{node[2]}\n" }
print "*****\n" #Separates node list and apomophy list
apomorphy_hash.each do |name, list|
  print "#{name}\t"
  list.each_with_index { |id, i| print i == 0 ? "#{id}" : "\t#{id}" }
  print "\n"
end
