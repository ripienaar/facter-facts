if File.exist?("/etc/facts.txt")
    File.readlines("/etc/facts.txt").each do |line|
        if line =~ /^(.+)=(.+)$/
            var = $1; val = $2

            Facter.add(var) do
                setcode { val }
            end
        end
    end
end
