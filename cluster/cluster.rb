if Facter.hostname =~ /(\d+)$/
    hostname = $1.to_i

    # set this to the amount of clusters
    # you'd like to create
    clusters = 3

    NATOALPHA = ["alfa", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel",
                 "india", "juliet", "kilo", "lima", "mike", "november", "oscar", "papa",
                 "quebec", "romeo", "sierra", "tango", "uniform", "victor", "whiskey",
                 "xray", "yankee", "zulu"]

    cluster = NATOALPHA[hostname % clusters]

    Facter.add(:cluster) do
        setcode { cluster }
    end
end
