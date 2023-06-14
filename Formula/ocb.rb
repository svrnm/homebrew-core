class Ocb < Formula
  desc "Generate a custom OpenTelemetry Collector binary based on a given configuration"
  homepage "https://opentelemetry.io/docs/collector/custom-collector/"
  url "https://github.com/open-telemetry/opentelemetry-collector/archive/refs/tags/cmd/builder/v0.79.0.tar.gz"
  sha256 "bf7f325eb10b57566654c573f6d33fa74ce368b67b001ba4b5aecbe811374aed"
  license "Apache-2.0"
  head "https://github.com/open-telemetry/opentelemetry-collector.git", branch: "main"

  depends_on "go" => :build

  def install
    cd "cmd/builder" do
      system "go", "build", *std_go_args(ldflags: "-s -w")
    end
  end

  test do
    (testpath/"manifest.yaml").write <<~EOS
      dist:
        name: otelcol-dev
        description: Basic OTel Collector distribution for Developers
        output_path: ./otelcol-dev
    EOS
    system bin/"ocb", "--config", "manifest.yaml"
  end
end
