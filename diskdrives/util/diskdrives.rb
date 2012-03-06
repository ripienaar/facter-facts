# A base module for collecting Disk Drive-related
# information from all kinds of platforms.
module Facter::Util::DiskDrives
    # platforms we work on
    def self.supported_platforms
        [:linux]
    end

    def self.drives
        @drivedata = Hash.new

        ["xvd", "ide", "scsi", "cciss"].each do |t|
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
                @drivedata[d][:model] = get_file_contents("/proc/ide/#{d}/model", "unknown") if File.exists?("/proc/ide")
                @drivedata[d][:size] = get_file_contents("/sys/block/#{d}/size", 0) if File.exists?("/sys/block")
                @drivedata[d][:smart] =  system("smartctl -i /dev/#{d} 2>&1 1>/dev/null") ? "yes" : "no"
                if @drivedata[d][:smart] == "yes"
                    smart_attr = %x{smartctl -A /dev/#{d}}
                end
                if smart_attr =~ /ID# ATTRIBUTE_NAME/
                    @drivedata[d][:smartattr] = "yes"
                else
                    @drivedata[d][:smartattr] = "no"
                end
            end if File.exists?("/proc/ide")
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
                @drivedata[d][:size] = get_file_contents("/sys/block/#{d}/size", 0) if File.exists?("/sys/block")
                @drivedata[d][:smart] =  "no"
                @drivedata[d][:smartattr] =  "no"
            end if File.exists?("/sys/block")
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
                @drivedata[d][:model] = get_file_contents("/sys/block/#{d}/device/model", "unknown") if File.exists?("/sys/block")
                @drivedata[d][:size] = get_file_contents("/sys/block/#{d}/size", 0) if File.exists?("/sys/block")
                @drivedata[d][:smart] =  system("smartctl -i /dev/#{d} 2>&1 1>/dev/null") ? "yes" : "no"
                if @drivedata[d][:smart] == "yes"
                    smart_attr = %x{smartctl -A /dev/#{d}}
                end
                if smart_attr =~ /ID# ATTRIBUTE_NAME/
                    @drivedata[d][:smartattr] = "yes"
                else
                    @drivedata[d][:smartattr] = "no"
                end
            end if File.exists?("/sys/block")
        else
            raise ArgumentError, "Not supported on kernel %s" %  Facter.value(:kernel)
        end
    end

    def self.get_cciss_data
        case Facter.value(:kernel)
        when 'Linux'
            Dir.open("/sys/block").entries.grep(/^cciss/).each do |d|
                @drivedata[d] = {}

                @drivedata[d][:type] = "cciss"
                @drivedata[d][:model] = "HP Logical Disk"
                @drivedata[d][:size] = get_file_contents("/sys/block/#{d}/size", 0) if File.exists?("/sys/block")
                @drivedata[d][:smart] =  "no"
                @drivedata[d][:smartattr] =  "no"
            end if File.exists?("/sys/block")
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
# diskdrives.rb
# Try to get additional Facts about the machine's disk drives

drives = Facter::Util::DiskDrives.drives

if !(['vserver', 'kvm'].include?(Facter.value(:virtual)))
then
  Facter.add(:diskdrives) do
    confine :kernel => Facter::Util::DiskDrives.supported_platforms
    setcode do
      drives.collect do |drive, data|
        drive
      end.sort.join(",")
    end
  end

  begin
      diskdrives_smart = drives.collect do |drive, data|
        drive if data[:smart] == 'yes'
      end.compact!.sort.join(",")

      Facter.add(:diskdrives_smart) do
        confine :kernel => Facter::Util::DiskDrives.supported_platforms
        setcode do
          diskdrives_smart
        end
      end

      diskdrives_smartattr = drives.collect do |drive, data|
        drive if data[:smartattr] == 'yes'
      end.compact!.sort.join(",")

      Facter.add(:diskdrives_smartattr) do
        confine :kernel => Facter::Util::DiskDrives.supported_platforms
        setcode do
          diskdrives_smartattr
        end
      end
  rescue
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
end

# vi:tabstop=4:expandtab:ai
