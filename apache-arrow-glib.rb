class ApacheArrowGlib < Formula
  desc "GObject Introspection files of Apache Arrow"
  homepage "https://arrow.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi/arrow/arrow-0.12.0/apache-arrow-0.12.0.tar.gz"
  mirror "https://archive.apache.org/dist/arrow/arrow-0.12.0/apache-arrow-0.12.0.tar.gz"
  sha256 "34dae7e4dde9274e9a52610683e78a80f3ca312258ad9e9f2c0973cf44247a98"
  head "https://github.com/apache/arrow.git"

  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "apache-arrow"
  depends_on "gettext"
  depends_on "glib"

  def install
    cd "c_glib" do
      system "./configure", "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <arrow-glib/arrow-glib.h>
      int main(void){
        GArrowNullArray *array = garrow_null_array_new(10);
        return 0;
      }
    EOS
    apache_arrow = Formula["apache-arrow"]
    glib = Formula["glib"]
    flags = %W[
      -I#{include}
      -I#{apache_arrow.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -L#{lib}
      -L#{apache_arrow.opt_lib}
      -L#{glib.opt_lib}
      -DNDEBUG
      -larrow-glib
      -larrow
      -lglib-2.0
      -lgobject-2.0
      -lgio-2.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
