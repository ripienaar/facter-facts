# diskdrives.rb
# Try to get additional Facts about the machine's disk drives

require 'facter/util/diskdrives'

drives = Facter::Util::DiskDrives.drives

Facter.add(:diskdrives) do
    confine :kernel => Facter::Util::DiskDrives.supported_platforms
    setcode do
        drives.collect do |drive, data|  
	    drive
	end.sort.join(",")
    end
end

drives.each do |drive, data|
    data.each do |key, val|
        Facter.add("disk#{key}_#{drive}") do
            confine :kernel => Facter::Util::DiskDrives.supported_platforms
            setcode do
                val
            end
        end
    end
end
