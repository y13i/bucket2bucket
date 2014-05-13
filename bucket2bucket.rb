require "aws-sdk"
require "optparse"
require "thread"

require_relative "plogger"

DEFAULT_REGION = "ap-northeast-1"

def log
  @log ||= PLogger.new "#{__FILE__}.log"
end

def options
  @options ||= OptionParser.new do |o|
    o.banner = "Usage: #{File.basename __FILE__} [options]"
    options = Hash.new

    o.on("-s", "--src-bucket BUCKET_NAME")  {|v| options[:src_bucket]        = v}
    o.on("-S", "--src-prefix PATH")         {|v| options[:src_prefix]        = v}
    o.on("-r", "--src-region REGION")       {|v| options[:src_region]        = v}
    o.on("-d", "--dest-bucket BUCKET_NAME") {|v| options[:dest_bucket]       = v}
    o.on("-D", "--dest-prefix PATH")        {|v| options[:dest_prefix]       = v}
    o.on("-R", "--dest-region REGION")      {|v| options[:dest_region]       = v}
    o.on("-i", "--access-key-id ID")        {|v| options[:access_key_id]     = v}
    o.on("-k", "--secret-access-key KEY")   {|v| options[:secret_access_key] = v}
    o.on("-v", "--verify")                  {|v| options[:verify]            = true}
    o.on("-t", "--threads THREAD_COUNT")    {|v| options[:threads]           = v.to_i}

    options[:threads]     ||= 4
    options[:src_prefix]  ||= ""
    options[:src_region]  ||= DEFAULT_REGION
    options[:dest_prefix] ||= ""
    options[:dest_region] ||= DEFAULT_REGION

    o.parse! ARGV
    break options
  end
end

def s3 region = DEFAULT_REGION
  iv_name = "@s3_#{region.gsub ?-, ?_}".intern
  instance_variable_get iv_name or instance_variable_set iv_name, AWS::S3.new(access_key_id: options[:access_key_id], secret_access_key: options[:secret_access_key], s3_endpoint: "s3-#{region}.amazonaws.com")
end

def src_bucket
  s3(options[:src_region]).buckets[options[:src_bucket]]
end

def dest_bucket
  s3(options[:dest_region]).buckets[options[:dest_bucket]]
end

def each_in_threads thread_count, enumerable
  queue = SizedQueue.new thread_count
  terminator = Object.new

  threads = thread_count.times.map do
    Thread.new do
      loop do
        item = queue.shift
        break if item.equal? terminator
        yield item
      end
    end
  end

  enumerable.each {|item| queue.push item}
  thread_count.times {queue.push terminator}
  threads.each &:join
  enumerable
end

log.info "Start."
log.debug options
start_at = Time.now

# require "pry"
# require "awesome_print"
# binding.pry

each_in_threads options[:threads], src_bucket.objects do |src_object|
  begin
    src_key  = src_object.key
    dest_key = options[:dest_prefix] + src_key

    next unless src_key.start_with? options[:src_prefix]

    dest_object = src_object.copy_to dest_bucket.objects[dest_key], server_side_encryption: src_object.server_side_encryption
    dest_object.acl = src_object.acl
    log.info "Copied: #{src_bucket.name}:#{src_key} => #{dest_bucket.name}:#{dest_key}"

    next unless options[:verify]

    if src_object.etag == dest_object.etag
      log.info "Verified: #{src_bucket.name}:#{src_key} <=> #{dest_bucket.name}:#{dest_key}"
    else
      log.warn "Verify failed: #{src_bucket.name}:#{src_key} <=> #{dest_bucket.name}:#{dest_key}"
    end
  rescue => e
    log.error e.inspect
  end
end

log.info "End (took #{Time.now - start_at} seconds)."
