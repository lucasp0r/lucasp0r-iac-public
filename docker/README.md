# DocPad Dockerfile

[Docker](http://docker.com) container to use [DocPad](http://docpad.org).


## Usage

### Install

Pull `docpad/docpad` from the Docker repository:

    docker pull docpad/docpad


Or build `docpad/docpad` from source:

    git clone https://github.com/docpad/dockerfile.git
    cd dockerfile
    docker build -t docpad/docpad .

### Run

Run the image, binding associated ports, and mounting the present working
directory:

    docker run -p 9778:9778 -v $(pwd):/app:rw docpad/docpad help

Append the DocPad command to the end of your `docker run` command. The above
example uses `help`.


## Services

Service     | Port | Usage
------------|------|------
DocPad      | 9778 | When using `docpad run`, visit `http://localhost:9778` in your browser


## Volumes

Volume          | Description
----------------|-------------
`/app`          | The location of the DocPad application root.
