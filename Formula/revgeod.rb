class Revgeod < Formula
  desc "A reverse Geo lookup service written in C, accessible via HTTP and backed by OpenCage and LMDB"
  homepage "https://github.com/jpmens/revgeod/"
  url "https://github.com/jpmens/revgeod/archive/0.2.2.tar.gz"
  sha256 "f0959b90bb16596d14b8e8d75e4897139b245be02f34f1c6b827906334170c7d"

  depends_on "libmicrohttpd"
  depends_on "lmdb"
  depends_on "curl"

  def install
    if (etc+"revgeod.sh").exist?
       copy(etc+"revgeod.sh", "/tmp/revgeod.sh.backup")
       ohai "Existing revgeod.sh has been copied to /tmp/revgeod.sh.backup"
    end

    ENV.deparallelize  # if your formula fails when building in parallel

    # Create our config.mk from scratch
    (buildpath+"config.mk").write config_mk

    system "make"
    # system "make", "install", "DESTDIR=#{prefix}"

    # Create the working directories
    (var/"revgeod").mkpath
    (var/"revgeod/geocache").mkpath

    sbin.install "revgeod"
    chmod 0755, sbin/"revgeod"

    (var/"revgeod").install "c-mini-test.sh"

    doc.install "README.md"

  end

  def post_install
      unless (etc+"revgeod.sh").exist?
         (etc+"revgeod.sh").write launch_script
         chmod 0755, etc/"revgeod.sh"
      end
  end

  test do
     system "true"
  end

  def caveats; <<-EOD
    Revgeod has been installed with a default configuration.
    You should change the configuration by editing and then
    launching:
        #{etc}/revgeod.sh
    EOD
  end

  def config_mk; <<-EOS
      # leave undefined if you don't want to use statsd
      # STATSDHOST="127.0.0.1"
      LMDB_DATABASE=    "/usr/local/var/revgeod/geocache/"
      LISTEN_HOST=      "127.0.0.1"
      LISTEN_PORT=	"8865"
      LIBS=		""
    EOS
  end

  def launch_script; <<~EOS
    #!/bin/sh
    # Launch script for Revgeod

    #:-- You must set a valid API key; you can get one at https://opencagedata.com
    export OPENCAGE_APIKEY=""

    #:-- The address/port to which we bind; warning: there is no authentication of
    #:-- any kind so limit carefully!
    export REVGEO_IP=127.0.0.1
    export REVGEO_PORT=8865

    exec "/usr/local/sbin/revgeod"
    EOS
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/etc/revgeod.sh"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{etc}/revgeod.sh</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{var}/revgeod</string>
    </dict>
    </plist>
    EOS
  end

end
