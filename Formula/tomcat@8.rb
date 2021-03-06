class TomcatAT8 < Formula
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-8/v8.5.28/bin/apache-tomcat-8.5.28.tar.gz"
  mirror "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.28/bin/apache-tomcat-8.5.28.tar.gz"
  sha256 "f2da60969b942ef60d12bda2fab6580be18895e34e3dce0ddd70f0fdaaed1a07"

  bottle :unneeded

  keg_only :versioned_formula

  option "with-fulldocs", "Install full documentation locally"

  depends_on :java => "1.7+"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-8/v8.5.28/bin/apache-tomcat-8.5.28-fulldocs.tar.gz"
    mirror "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.28/bin/apache-tomcat-8.5.28-fulldocs.tar.gz"
    sha256 "4ca9a62864a1d423b349947c2403dc3951aefb5404010484a0af6345bcdaf100"
  end

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]

    # Install files
    prefix.install %w[NOTICE LICENSE RELEASE-NOTES RUNNING.txt]
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (pkgshare/"fulldocs").install resource("fulldocs") if build.with? "fulldocs"
  end

  plist_options :manual => "catalina run"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Disabled</key>
        <false/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/catalina</string>
          <string>run</string>
        </array>
        <key>KeepAlive</key>
        <true/>
      </dict>
    </plist>
    EOS
  end

  test do
    ENV["CATALINA_BASE"] = testpath
    cp_r Dir["#{libexec}/*"], testpath
    rm Dir["#{libexec}/logs/*"]

    pid = fork do
      exec bin/"catalina", "start"
    end
    sleep 3
    begin
      system bin/"catalina", "stop"
    ensure
      Process.wait pid
    end
    assert_predicate testpath/"logs/catalina.out", :exist?
  end
end
