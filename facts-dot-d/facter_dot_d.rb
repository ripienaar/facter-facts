begin
    Dir.entries("/etc/facts.d").sort.each do |fact|
        begin
            next if fact =~ /^\./

            fact_file = File.join("/etc/facts.d", fact)
            extension = File.extname(fact)

            case extension
                when ".txt"
                    File.readlines(fact_file).each do |line|
                        if line =~ /^(.+)=(.+)$/
                            var = $1; val = $2

                            Facter.add(var) do
                                setcode { val }
                            end
                        end
                    end
                when ".json"
                    require 'json'

                    JSON.load(File.read(fact_file)).each_pair do |f, v|
                        Facter.add(f) do
                            setcode { v }
                        end
                    end
                when ".yaml"
                    require 'yaml'

                    YAML.load_file(fact_file).each_pair do |f, v|
                        Facter.add(f) do
                            setcode { v }
                        end
                    end
                else
                    if File.executable?(fact_file)
                        result = Facter::Util::Resolution.exec(fact_file)

                        result.split("\n").each do |line|
                            if line =~ /^(.+)=(.+)$/
                                var = $1; val = $2

                                Facter.add(var) do
                                    setcode { val }
                                end
                            end
                        end
                    end
            end
        rescue Exception => e
            puts("Failed to load fact #{fact_file}: #{e}")
        end
    end
rescue Exception => e
    Facter.debug("Failed to load facts from /etc/facts.d: #{e}")
end
