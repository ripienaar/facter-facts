# A base module for collecting Disk Drive-related
# information from all kinds of platforms.
module Facter::Util::DiskDrives
    # All the types of drives we know about
    DRIVETYPES = ["xvd", "ide", "scsi"]

    # platforms we work on
    def self.supported_platforms
        [:linux]
    end

    def self.drives
        @drivedata = Hash.new

        DRIVETYPES.each do |t|
            send("get_#{t}_data")
        end

        return @drivedata
    end

    private

    def self.get_ide_data
        case Facter.value(:kernel)
        when 'Linux'
            Dir.open("/proc/ide").entries.grep(/^hd/).each do |d|
                @drivedata[d] = {}

                @drivedata[d][:type] = "ide"
                @drivedata[d][:model] = get_file_contents("/proc/ide/#{d}/model", "unknown")
                @drivedata[d][:size] = get_file_contents("/sys/block/#{d}/size", 0)
            end
        else
            raise ArgumentError, "Not supported on kernel %s" %  Facter.value(:kernel)
        end
    end

    def self.get_xvd_data
        case Facter.value(:kernel)
        when 'Linux'
            Dir.open("/sys/block").entries.grep(/^x/).each do |d|
                @drivedata[d] = {}

                @drivedata[d][:type] = "xvd"
                @drivedata[d][:model] = "Xen Virtual Disk"
                @drivedata[d][:size] = get_file_contents("/sys/block/#{d}/size", 0)
            end
        else
            raise ArgumentError, "Not supported on kernel %s" %  Facter.value(:kernel)
        end
    end

    def self.get_scsi_data
        case Facter.value(:kernel)
        when 'Linux'
            Dir.open("/sys/block").entries.grep(/^s/).each do |d|
                @drivedata[d] = {}

                @drivedata[d][:type] = "scsi"
                @drivedata[d][:model] = get_file_contents("/sys/block/#{d}/device/model", "unknown")
                @drivedata[d][:size] = get_file_contents("/sys/block/#{d}/size", 0)
            end
        else
            raise ArgumentError, "Not supported on kernel %s" %  Facter.value(:kernel)
        end
    end

    def self.get_file_contents(file, default)
        return default unless File.exists?(file)

        # Using something like File.read(file) does not work when puppetd
        # runs in the background, the catalog run never starts, unknown reason
        %x{/bin/cat #{file}}.chomp
    end
end

# vi:tabstop=4:expandtab:ai
