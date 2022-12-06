#using 'aws' cloud provider to create the instance in below region
#This configuration uses a terraform.tfvars file to set values for the input variables of your configuration. Open the terraform.tfvars file to review its contents.
provider "aws" {
  region = var.region #us-east-1

  default_tags {
    tags = {
      terraform-circleci = "project"
    }
  }
}

#generating ranndom id for using below to create a bucket name
resource "random_uuid" "randomid" {} #The resource random_uuid generates random uuid string that is intended to be used as unique identifiers for other resources.

resource "aws_s3_bucket" "app" { #Terraform module which creates S3 bucket resources on AWS 🇺🇦
  tags = {
    Name          = "App Bucket"
    public_bucket = true #making bucket as public so that it will display to all the users of AWS account
  }

  bucket        = "${var.app}.${var.label}.${random_uuid.randomid.result}" #creating a bucket name by adding variables and random id result 
  force_destroy = true #Description: (Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable.
}

resource "aws_s3_object" "app" { #aws_s3_object_copy will also present in terraform resources
  acl          = "public-read" #(Optional) Canned ACL to apply. Defaults to private,Amazon S3 supports a set of predefined grants, known as canned ACLs. Each canned ACL has a predefined set of grantees and permissions. 
  key          = "index.html" #(Required) Name of the object once it is in the bucket
  bucket       = aws_s3_bucket.app.id #(Required) Name of the bucket to put the file in.
  content      = file("./assets/index.html")#(Required) Specifies the source object for the copy operation. You specify the value in one of two formats. For objects not accessed through an access point, specify the name of the source bucket and the key of the source object, separated by a slash (/). For example, testbucket/test1.json. 
  content_type = "text/html"# (Optional) Standard MIME type describing the format of the object data, e.g. application/octet-stream. All Valid MIME Types are valid for this input.
}

resource "aws_s3_bucket_acl" "bucket" { #Provides an S3 bucket ACL resource.
  bucket = aws_s3_bucket.app.id #(Required, Forces new resource) The name of the bucket.
  acl    = "public-read" #(Optional, Conflicts with access_control_policy) The canned ACL to apply to the bucket.
}
#You can use Amazon S3 to host a static website. On a static website, individual webpages include static content. They might also contain client-side scripts.

#By contrast, a dynamic website relies on server-side processing, including server-side scripts, such as PHP, JSP, or ASP.NET. Amazon S3 does not support server-side scripting, but AWS has other resources for hosting dynamic websites. To learn more about website hosting on AWS, see Web Hosting.
resource "aws_s3_bucket_website_configuration" "terramino" {#Provides an S3 bucket website configuration resource. For more information, see Hosting Websites on S3.
  bucket = aws_s3_bucket.app.bucket #(Required, Forces new resource) The name of the bucket.

  index_document {#(Optional, Required if redirect_all_requests_to is not specified) The name of the index document for the website detailed below.
    suffix = "index.html" #(Required) A suffix that is appended to a request that is for a directory on the website endpoint. For example, if the suffix is index.html and you make a request to samplebucket/images/, the data that is returned will be for the object with the key name images/index.html. The suffix must not be empty and must not include a slash character.
  }

  error_document { #(Optional, Conflicts with redirect_all_requests_to) The name of the error document for the website detailed below.
    key = "error.html"#(Required) The object key name to use when a 4XX class error occurs.
  }
}
