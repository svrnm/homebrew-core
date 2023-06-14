class OpentelemetryCollectorContrib < Formula
  desc "OpenTelemtry collector distribution containing both core and contrib components"
  homepage "https://opentelemetry.io/docs/collector/"
  url "https://github.com/open-telemetry/opentelemetry-collector-releases/archive/refs/tags/v0.79.0.tar.gz"
  sha256 "25dad14c6978343bf297a9f42f9392a710de59b537a9e0f127c3e0c8d2d4c5dc"
  license "Apache-2.0"
  head "https://github.com/open-telemetry/opentelemetry-collector-releases.git", branch: "main"

  depends_on "go" => :build
  depends_on "ocb" => :build

  def install
    ENV["DISTRIBUTIONS"] = "otelcol-contrib"
    system "make", "build"
    bin.install "distributions/otelcol-contrib/_build/otelcol-contrib" => "otelcol-contrib"
  end

  test do
    (testpath/"config.yaml").write <<~EOS
      receivers:
        otlp:
          protocols:
            grpc:
      exporters:
        logging:
      service:
        pipelines:
          traces:
            receivers: [otlp]
            exporters: [logging]
    EOS
    fork do
      system bin/"otelcol-contrib", "--config", "config.yaml"
    end
    sleep 2
    assert_match "{\"partialSuccess\":{}}",
      shell_output("curl -s -H 'Content-Type: application/json' -X POST -d '{}' localhost:4318/v1/traces")
  end
end
