class ApacheArrow < Formula
  desc "Columnar in-memory analytics layer designed to accelerate big data"
  homepage "https://arrow.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi/arrow/arrow-0.12.0/apache-arrow-0.12.0.tar.gz"
  mirror "https://archive.apache.org/dist/arrow/arrow-0.12.0/apache-arrow-0.12.0.tar.gz"
  sha256 "34dae7e4dde9274e9a52610683e78a80f3ca312258ad9e9f2c0973cf44247a98"
  head "https://github.com/apache/arrow.git"

  depends_on "autoconf" => :build
  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "jemalloc"
  depends_on "python" => :optional
  depends_on "python@2" => :optional

  needs :cxx11

  def install
    ENV.cxx11
    args = []

    if build.with?("python") && build.with?("python@2")
      odie "Cannot provide both --with-python and --with-python@2"
    end
    Language::Python.each_python(build) do |python, _version|
      args << "-DARROW_PYTHON=1" << "-DPYTHON_EXECUTABLE=#{which python}"
    end

    cd "cpp" do
      system "cmake", ".", *std_cmake_args, *args, '-DARROW_BUILD_TESTS=ON'
      system "make", "unittest"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "arrow/api.h"
      int main(void)
      {
        arrow::int64();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++11", "-I#{include}", "-L#{lib}", "-larrow", "-o", "test"
    system "./test"
  end
end
