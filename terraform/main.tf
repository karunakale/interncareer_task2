provider "aws" {
 access_key = "My_ACCESS_KEY"
  secret_key = "MY_SECRTE_KEY"
  region = "ap-south-1"
}

resource "aws_vpc" "app_vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "app_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "IGW"
  }
}


resource "aws_subnet" "public_sub" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet"
  }
}

resource "aws_route" "route_to_igw_default" {
  route_table_id         = aws_vpc.app_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id


}


resource "aws_security_group" "test-sg" {
    name = "test-sg"
    description = "Enable web traffic for the project"
    vpc_id = aws_vpc.app_vpc.id
  //Inbound rule
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }

  ingress {
    from_port   = 8080  # Assuming HTTP runs on port 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from anywhere
  }

  // Outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "machine1"{
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  key_name = "linuxgit"
  subnet_id = aws_subnet.public_sub.id
  security_groups  = [aws_security_group.test-sg.id]
  tags = {
    Name = "test1"
  }

}
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-interncareertask2"
}

resource "aws_s3_bucket_ownership_controls" "my_bucket_owner" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
  
  resource "aws_s3_bucket_acl" "my_bucket_owner" {
   depends_on = [
    aws_s3_bucket_public_access_block.my_bucket_access,
    aws_s3_bucket_ownership_controls.my_bucket_owner,
    ]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read"    
}

# Attach a bucket policy to allow public read access
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}

 resource "aws_s3_object" "Index" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
   
 }

 resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
   
 }

 resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }
   
   error_document {
     key = "error.html"
   }
   depends_on = [ aws_s3_bucket_acl.my_bucket_owner ]
 }
