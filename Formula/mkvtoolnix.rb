class Mkvtoolnix < Formula
  desc "Matroska media files manipulation tools"
  homepage "https://www.bunkus.org/videotools/mkvtoolnix/"
  url "https://mkvtoolnix.download/sources/mkvtoolnix-22.0.0.tar.xz"
  sha256 "88c5074d6731b65d5c2ddd02113ae064373eb83ef3e6e00a04876f88c0be7f67"
  revision 2

  bottle do
    sha256 "0d11fd3e404ec0e6363c4aa1eafc436d6c388a441435e74acb2a0a27492841e7" => :high_sierra
    sha256 "868646456bb41ca29452f23165c75dfbefdaede16c3bc1848cb9da7b77e0c0c8" => :sierra
    sha256 "0605e6778081f20049c4a8872fb75a49c72f8c1ce2ed6568efc441ca6e2e1e96" => :el_capitan
  end

  head do
    url "https://github.com/mbunkus/mkvtoolnix.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  option "with-qt", "Build with Qt GUI"

  deprecated_option "with-qt5" => "with-qt"

  depends_on "docbook-xsl" => :build
  depends_on "pkg-config" => :build
  depends_on "pugixml" => :build
  depends_on "ruby" => :build if MacOS.version <= :mountain_lion
  depends_on "boost"
  depends_on "libebml"
  depends_on "libmatroska"
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "flac" => :recommended
  depends_on "libmagic" => :recommended
  depends_on "gettext" => :optional
  depends_on "qt" => :optional
  depends_on "cmark" if build.with? "qt"

  needs :cxx11

  def install
    ENV.cxx11

    features = %w[libogg libvorbis libebml libmatroska]
    features << "flac" if build.with? "flac"
    features << "libmagic" if build.with? "libmagic"

    extra_includes = ""
    extra_libs = ""
    features.each do |feature|
      extra_includes << "#{Formula[feature].opt_include};"
      extra_libs << "#{Formula[feature].opt_lib};"
    end
    extra_includes.chop!
    extra_libs.chop!

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --with-boost=#{Formula["boost"].opt_prefix}
      --with-docbook-xsl-root=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl
      --with-extra-includes=#{extra_includes}
      --with-extra-libs=#{extra_libs}
    ]

    if build.with?("qt")
      qt = Formula["qt"]

      args << "--with-moc=#{qt.opt_bin}/moc"
      args << "--with-uic=#{qt.opt_bin}/uic"
      args << "--with-rcc=#{qt.opt_bin}/rcc"
      args << "--enable-qt"
    else
      args << "--disable-qt"
    end

    system "./autogen.sh" if build.head?

    system "./configure", *args

    system "rake", "-j#{ENV.make_jobs}"
    system "rake", "install"
  end

  test do
    mkv_path = testpath/"Great.Movie.mkv"
    sub_path = testpath/"subtitles.srt"
    sub_path.write <<~EOS
      1
      00:00:10,500 --> 00:00:13,000
      Homebrew
    EOS

    system "#{bin}/mkvmerge", "-o", mkv_path, sub_path
    system "#{bin}/mkvinfo", mkv_path
    system "#{bin}/mkvextract", "tracks", mkv_path, "0:#{sub_path}"
  end
end
