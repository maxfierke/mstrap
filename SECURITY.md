# Security Policy

`mstrap` aims to produce a development environment with secure defaults.

This is why we require remote bootstrapping to use HTTPS, encourage the use of
revision SHAs or checksums when using managed profiles, setup disk encryption
(on macOS), enable AppArmor (on Ubuntu), and other good practices.

That being said, `mstrap` delegates to other tools we trust, such as Homebrew,
Docker, asdf-vm, etc. for tasks to which those tools are suited. Many of these
tools require some level of administrator privilege for the trade-off of a good
developer experience and convenience.

As such, we are particularly sensitive to any vulnerabilities that could result
in code being executed that the user does not expect (both nefariously or otherwise),
especially through the use of these tools.

Remote code execution, command injection, and secrets disclosure vulnerabilities are
the largest areas of concern, so please follow the instructions below if you notice
a potential concern.

Because we delegate to other tools, the issue may be found not to be rooted in `mstrap`
in which case we can point you to where to responsibly disclose.

## Reporting a Vulnerability

Please contact me (@maxfierke) directly over email (see GitHub profile) to report
any security vulnerabilities you find.
