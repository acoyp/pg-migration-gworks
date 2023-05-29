resource "aws_vpc" "my_vpc" {
  cidr_block = "172.70.0.0/16"  # Replace with your desired CIDR block
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.70.1.0/24"  # Replace with your desired CIDR block for the public subnet
  availability_zone = "us-east-1a"   # Replace with your desired availability zone

  tags = {
    Name = "Public Subnet A"
    # Add more tags as needed
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.70.2.0/24"  # Replace with your desired CIDR block for the public subnet
  availability_zone = "us-east-1b"   # Replace with your desired availability zone

  tags = {
    Name = "Public Subnet B"
    # Add more tags as needed
  }
}
output subnet_a {
  value       = aws_subnet.public_subnet_1.id
  sensitive   = false
  description = "description"
  depends_on  = [aws_subnet.public_subnet_1]
}
output subnet_b {
  value       = aws_subnet.public_subnet_2.id
  sensitive   = false
  description = "description"
  depends_on  = [aws_subnet.public_subnet_2]
}
