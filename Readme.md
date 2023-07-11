# PDF2John Docker Image

This Docker image wraps the `pdf2john.pl` script, which is used to extract hashes from PDF files. These hashes can then be cracked using a tool such as Hashcat.

**This build expects the target file to be placed under `/mnt/target/target.pdf`.** 

## Building the Image

To build the image, use the Docker command line interface:

```bash
docker build -t pdf2john .
```

When you run this command, Docker will start building the image, and you should see output similar to the following:

```
[+] Building 6.0s (10/10) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 593B
 => [internal] load .dockerignore
 => => transferring context: 2B
 => [internal] load metadata for docker.io/library/perl:slim
 => [1/5] FROM docker.io/library/perl:slim@sha256:552ccdeeef4e708cdf97679731eeef4e6ab59caad5d989e7b6ecbf5838f5be1a
 => => resolve docker.io/library/perl:slim@sha256:552ccdeeef4e708cdf97679731eeef4e6ab59caad5d989e7b6ecbf5838f5be1a
 => => sha256:552ccdeeef4e708cdf97679731eeef4e6ab59caad5d989e7b6ecbf5838f5be1a 984B / 984B
 => => sha256:e4b48ad0270b7a9cf007dd3f4a6cdbfa037e032bb19691101d640a9ec6a0272f 948B / 948B
 => => sha256:7fd0a30b791f5216a2d7f9e6ffb97106350d961fee200e85944c1b65ad96cec0 4.88kB / 4.88kB
 => => sha256:3ae0c06b4d3aa97d7e0829233dd36cea1666b87074e55fea6bd1ecae066693c7 29.15MB / 29.15MB
 => => sha256:226ae465584f1cc0bfd6631bb5f90b7e7e868794d67df807ab104aeb9f5c00d2 169B / 169B
 => => sha256:9fce08f7246c5c433a23f65caedf4b9855c9db733bce12547ee85a305fcabbb8 27.28MB / 27.28MB
 => => extracting sha256:3ae0c06b4d3aa97d7e0829233dd36cea1666b87074e55fea6bd1ecae066693c7
 => => extracting sha256:226ae465584f1cc0bfd6631bb5f90b7e7e868794d67df807ab104aeb9f5c00d2
 => => extracting sha256:9fce08f7246c5c433a23f65caedf4b9855c9db733bce12547ee85a305fcabbb8
 => [internal] load build context
 => => transferring context: 350.44kB
 => [2/5] WORKDIR /app
 => [3/5] ADD lib /app/lib
 => [4/5] COPY ./pdf2john.pl /app/
 => [5/5] RUN chmod +x /app/pdf2john.pl
 => exporting to image
 => => exporting layers
 => => writing image sha256:04b5144897afb00afc966ddc791daab236aca44eb2839bf4447c5f2212ed1beb
 => => naming to docker.io/library/pdf2john
```

After the image is built, it is named pdf2john and stored locally. You can now use this Docker image to run the pdf2john.pl script.

# Hashcat Demonstration

## Extract and Identify the Hash

1. Use `pdf2john.pl` to get hash from the target PDF file:

    ```bash
    cp /path/to/source/document.pdf target.pdf
    docker run -it -v $(pwd):/mount/target/ --rm pdf2john
    ```
This command will print out a line with the format `<filename>:$pdf$...`. 

2. Match the hash type in the Hashcat's example hashes page (https://hashcat.net/wiki/doku.php?id=example_hashes). Our example line starts with `$pdf$5*5`, it corresponds to Hashcat's mode `10600`.

3. Remove the filename from the hash (the part before `:$pdf$...`) and save the hash into a file.  

    ```bash
    echo "$pdf$5*5*256*-1028*1*16*20583814402184226866485332754315*127*f95d927a94829db8e2fbfbc9726ebe0a391b22a084ccc2882eb107a74f7884812058381440218422686648533275431500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000*127*00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000*32*0000000000000000000000000000000000000000000000000000000000000000*32*0000000000000000000000000000000000000000000000000000000000000000" > hash
    ```

    You can use cut to help here:

    ```bash
    docker run -it -v $(pwd):/mount/target/ --rm pdf2john  | cut -f 2 -d ":" > hash
    ```

 4. Use Hashcat to Crack the Hash - in this case using a dictionary containing the word hashcat

 	```bash
 	❯ hashcat -a 0 -m 10600 hash dict
	hashcat (v6.2.6) starting

	* Device #2: Apple's OpenCL drivers (GPU) are known to be unreliable.
             You have been warned.

    [...]

    Approaching final keyspace - workload adjusted.

	$pdf$5*5*256*-1028*1*16*20583814402184226866485332754315*127*f95d927a94829db8e2fbfbc9726ebe0a391b22a084ccc2882eb107a74f7884812058381440218422686648533275431500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000*127*00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000*32*0000000000000000000000000000000000000000000000000000000000000000*32*0000000000000000000000000000000000000000000000000000000000000000:hashcat
	```