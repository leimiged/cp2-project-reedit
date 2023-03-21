provider "aws" {
  region = "us-west-1"
  
}

resource "aws_instance" "linux" {
  instance_type = "t2.micro"
  ami           = "0d50e5e845c552faf"

  tags = {
    Name = "Aula3"
  }
}