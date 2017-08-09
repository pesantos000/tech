# Simple terraform file to create simple ubuntu image 

provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"

  tags {
   Name = "terraform-example"
  }
}
