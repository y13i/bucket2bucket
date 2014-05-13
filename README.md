# bucket2bucket.rb

## What's this

A ruby script to copy every objects from a Amazon S3 bucket to another.

## Requirements

* Recent Ruby (2.0.0 or later maybe)
* aws-sdk

## Usage

    Usage: bucket2bucket.rb [options]
        -s, --src-bucket BUCKET_NAME   # Name of "source" bucket.
        -S, --src-prefix PATH          # Prefix of source objects. If "foo/" specified, only objects under "foo" folder in source bucket will be copied. Default is all objects.
        -r, --src-region REGION        # Region of source bucket. Default is Tokyo (ap-northeast-1).
        -d, --dest-bucket BUCKET_NAME  # Name of "destination" bucket.
        -D, --dest-prefix PATH         # Prefix of destination object. If "bar/" specified, copied object will be placed into "bar" folder in destination bucket. Default is root.
        -R, --dest-region REGION       # Region of destination bucket. Default is Tokyo (ap-northeast-1).
        -i, --access-key-id ID         # AWS Access Key ID. If you use IAM role on EC2 instance, no need to specify.
        -k, --secret-access-key KEY    # AWS Secret Access Key. If you use IAM role on EC2 instance, no need to specify.
        -v, --verify                   # If specified, source and destination objects are verified by their MD5 ETags.
        -t, --threads THREAD_COUNT     # How many concurrent threads to request object copying. Default is 4. "-t 10" can be 9 times faster than "-t 1" (tested on my laptop).

## Example

    ruby bucket2bucket.rb -i AQWERTYUIOP -k asdfghjklzxcvbnmqwertyuiop -s some-bucket -d other-bucket -D copied-from-some-bucket/ -v -t 10
