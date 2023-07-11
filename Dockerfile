# Use an existing docker image which has Perl already installed
FROM perl:slim

# Set the working directory in the container
WORKDIR /app

# Copy the required Perl libraries from your local system to the Docker image
ADD lib /app/lib

# Copy your Perl script to the Docker image
COPY ./pdf2john.pl /app/

# Change permissions on the script to make it executable
RUN chmod +x /app/pdf2john.pl

# Set the command that will be executed when Docker runs your container
CMD ["/app/pdf2john.pl", "/mount/target/target.pdf"]