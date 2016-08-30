require 'yaml'
require 'csv'
require 'net/ssh'


class DiskReporter
  def initialize
    @config = YAML.load_file("server_config.yml")
  end

  def check
    $svary =[]
    $hostary =[]
    @config.each do |info|
         Net::SSH.start(info["server_name"],info["connect_user"],:keys => ['AWS_Book_key.pem']) do |ssh|
         @ary = ssh.exec!('df -h | sed -e 1d').split(" ").each_slice(6).to_a
         @hostname = ssh.exec!('uname -n').split(" ")
         end
      $svary.push(@ary)
      $hostary.push(@hostname)
    end
  end

  def outputcsv(svary,hostary)
    header = %w/DeviceName DiskInfo/
    filepath = 'report.csv'
    file = CSV.open(filepath, "a",:encoding => "SJIS" , :headers => header, :write_headers => true)
    $hostary.each do |arryhost|
      file.puts arryhost
      $svary.each do |arry1|
         arry1.each do |arry2|
           file.puts arry2
         end
      end
    end
  end
end
#
obj = DiskReporter.new
obj.check
obj.outputcsv($svary,$hostary)
