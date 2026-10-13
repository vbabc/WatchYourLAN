# Hardware-column variant

This fork is based on upstream WatchYourLAN 2.1.4.

The dashboard shows the complete Hardware value instead of its first twelve
characters. Long vendor names wrap inside the table cell. The tooltip remains
available. Device naming, Known flags, scanning and database behavior use the
unchanged upstream application code.

The Docker build compiles the frontend before embedding its assets in the Go
binary. The runtime is based on the pinned upstream 2.1.4 image to retain its
existing ARP scanner and runtime dependencies.

GitHub Actions publishes the `linux/amd64` image to
`ghcr.io/vbabc/watchyourlan` with a `2.1.4-hardware-full` tag, a full commit-SHA
tag, and `latest`. Deployments can pin the published digest for reproducibility.

Keep existing `/data/WatchYourLAN` persistent storage when changing the image.
Back up the live SQLite database consistently before updating. Do not copy
device lists, databases, private network configuration or credentials into this
repository or image.
