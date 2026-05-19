# Use an existing docker image which has Perl already installed
# Pinned to 5.40.2-slim — update intentionally when upgrading Perl
FROM perl:5.40.2-slim AS runtime

# Set the working directory in the container
WORKDIR /app

# Copy the required Perl libraries from your local system to the Docker image
COPY lib /app/lib

# Copy your Perl script to the Docker image
COPY ./pdf2john.pl /app/

# Change permissions on the script to make it executable
RUN chmod +x /app/pdf2john.pl

# Set the command that will be executed when Docker runs your container
CMD ["/app/pdf2john.pl", "/mount/target/target.pdf"]

# -------------------------------------------------------------------
# test stage — build with: docker build --target test .
# Runs pdf2john.pl against the committed fixture and asserts $pdf$ output.
# Not part of the default build target.
# -------------------------------------------------------------------
FROM runtime AS test
COPY tests/fixtures/protected.pdf /tmp/test.pdf
RUN perl /app/pdf2john.pl /tmp/test.pdf | grep -q '\$pdf\$' \
    && echo "PASS: pdf2john smoke test" \
    || { echo "FAIL: no \$pdf\$ hash in output"; exit 1; }