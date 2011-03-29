
hash = Hash.new

File.open(ARGV[0]) do |infile|
  while (line = infile.gets)
   if (line[0]!='>' )
        next;
   end
  items = line.split('|')
   hash.store(items[0].strip,line)
  end
end

 #puts hash
File.open(ARGV[1])do |infile|
  while (line = infile.gets)
   if (line[0]=='>' )
     puts hash[line.strip]
   else
     puts line
   end
  end
end

