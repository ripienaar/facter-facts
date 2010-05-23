require 'find'

if File.exists?("/etc/sysconfig/network-scripts")
    Find.find("/etc/sysconfig/network-scripts") do |path|
        if (path =~ /ifcfg-(.+)$/)
            interface = $1
            File.open(path).each do |line|
                if line =~ /^HWADDR=(.+)$/
                    mac = $1
                    Facter.add("hwaddr_#{interface}") do
                        setcode { mac }
                    end
                end
            end
        end
    end
end
