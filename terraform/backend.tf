terraform {
  backend "s3" {
    bucket = "zoltans3bucket"
    key = "zoltans3bucket/statefolder/statefile"
    region = "eu-north-1"
    encrypt = true
  }
}
