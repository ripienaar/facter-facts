Facter.add(:puppet_enabled) do
    lockfile = "/var/lib/puppet/state/puppetdlock"

    if File.exists?(lockfile)
        # if the lock file exist and has no PID in it, then puppetd is
        # disabled, if there's a PID then its running or dead unexpectedly
        if File::Stat.new(lockfile).zero?
            setcode { "0" }
        else
            setcode { "1" }
        end
    else
        setcode { "1" }
    end
end
