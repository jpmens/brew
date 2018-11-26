class Revgeod < Formula
  desc "A reverse Geo lookup service written in C, accessible via HTTP and backed by OpenCage and LMDB"
  homepage "https://github.com/jpmens/revgeod/"
  url "https://github.com/jpmens/revgeod/archive/0.1.2.tar.gz"
  version "0.1.2"
  sha256 "53db3111f8df95cf11da736e85a228d58bbb5373f3af640eb6ee6454103b3eae"

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

    sbin.install "revgeod"
    chmod 0755, sbin/"revgeod"

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
      LISTEN_PORT=	"8865"
      LIBS=		""
    EOS
  end

  def launch_script; <<-EOS
    #!/bin/sh
    # Launch script for Revgeod

    #:-- You must set a valid API key
    export OPENCAGE_APIKEY=""
    export REVGEO_IP=127.0.0.1
    export REVGEO_PORT=8865

    exec "/usr/local/sbin/revgeod"
    EOS
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/etc/revgeod.sh"

  def plist; <<-EOS
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
