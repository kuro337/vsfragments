FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache curl jq tar xz git

RUN ZIG_URL=$(curl -s https://ziglang.org/download/index.json | jq -r '.master."aarch64-linux".tarball') && \
  curl -L $ZIG_URL -o zigmaster.tar.xz

RUN mkdir zig-dist && \
  tar -xJf zigmaster.tar.xz -C zig-dist --strip-components=1 && \
  mv zig-dist/zig /usr/local/bin/ && \
  mv zig-dist/lib /usr/local/lib/zig && \
  rm -rf zig-dist zigmaster.tar.xz

RUN zig version || exit 1

RUN cat <<EOF > hello.zig
const std = @import("std");
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, {s}!\n", .{"world"});
}
EOF

# validate build + compile works
RUN zig build-exe hello.zig
RUN ./hello

