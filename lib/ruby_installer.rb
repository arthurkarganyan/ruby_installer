require "ruby_installer/version"

module RubyInstaller
  class Error < StandardError;
  end

  class CLI < Thor
    desc "install 2.5.3 root@0.0.0.0", "Install ruby/rbenv on server"

    def install(version, ssh_string)
      user, ip = ssh_string.split("@")
      puts "Password for #{user}"
      password = $stdin.gets.chomp

      ssh = ::Net::SSH.start(ip, user, password: password)

      ssh.exec!("echo #{password} | sudo -S apt update") do |channel, stream, data|
        print data
      end

      cmd = "apt install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev"
      ssh.exec!("echo #{password} | sudo -S #{cmd}") do |channel, stream, data|
        print data
      end

      cmds = [
          "git clone https://github.com/rbenv/rbenv.git ~/.rbenv",
          # "git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build",
          "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~/.bash_profile",
          "echo 'eval \"$(rbenv init -)\"' >> ~/.bash_profile",
          "source $HOME/.bash_profile",
          "rbenv install -v #{version}" ,
          "rbenv global #{version}",
          "gem install bundler"
      ]

      ssh.exec!(cmds.join(" && ")) do |channel, stream, data|
        print data
      end

    end
  end
end
