# vpnc homebrew formula
class Vpnc < Formula
  desc     'client for cisco vpn concentrator'
  homepage 'https://www.unix-ag.uni-kl.de/~massar/vpnc/'
  url      'http://svn.unix-ag.uni-kl.de/vpnc/', using: :svn
  version  '0.5.3-trunk'

  depends_on 'libgcrypt'  => :build
  depends_on 'pkg-config' => :build
  depends_on 'gnutls'     => :build
  depends_on 'nettle'     => :build
  depends_on 'libtasn1'   => :build
  depends_on 'p11-kit'    => :build

  def install
    ENV.deparallelize

    # inline patching for the port
    inreplace 'trunk/Makefile' do |s|
      s.change_make_var! 'PREFIX', prefix
      s.change_make_var! 'ETCDIR', (etc + 'vpnc')
    end
    inreplace 'trunk/config.c' do |s|
      s.gsub! '/etc/vpnc', (etc + 'vpnc')
      s.gsub! '/var/run/vpnc', (var + 'run/vpnc')
    end
    inreplace ['trunk/vpnc-script', 'trunk/vpnc-disconnect'] do |s|
      s.gsub! '/var/run/vpnc', (var + 'run/vpnc')
    end
    inreplace 'trunk/vpnc.8.template' do |s|
      s.gsub! '/etc/vpnc', (etc + 'vpnc')
    end

    system 'cd trunk && make'
    (var + 'run/vpnc').mkpath
    system 'cd trunk && make install'
  end

  test do
    system 'vpnc', '--version'
  end
end
