require 'net/http'
require "uri"
#require 'rest-client'
require 'json'
require 'unirest' # see http://unirest.io/ruby.html
require 'pp'

class Rabbitmq
  def initialize (username, password, url, threshold) 
    @username = username
    @password = password
    @url = url+":15672/api/"
    @threshold = threshold
  end


  def queue_info(vhost,name)
    url = @url+"queues/%2F#{vhost}/#{name}"
    res = Unirest.get(url, headers: {}, 
                      parameters: nil, 
                      auth:{:user=>"#{@username}", :password=>"#{@password}"}
                     )
    puts res.body
    return res.body
  end

  def list_queues
    url = @url+"queues?sort=messages_ready&sort_reverse=true"
    res = Unirest.get(url, headers: {}, 
                      parameters: nil, 
                      auth:{:user=>"#{@username}", :password=>"#{@password}"}
                     )
    #pp res.body[0]
    #pp res.body[0]["vhost"]
    #pp res.body[0]["messages_ready"]
    sum={}
    s = 0
    res.body.each {|r|
      s += r["messages_ready"].to_i
      if r["messages_ready"].to_i >= @threshold.to_i
        n = r["name"]
        m = r["messages_ready"].to_i 
        sum["#{n}"] = m
      end
    }
    printf "total: "; puts s
    pp sum.sort_by {|k,v| v}.reverse
  end

  def purge_queue (vhost, name)
    url = @url+"queues/%2F#{vhost}/#{name}/contents"
    res = Unirest.delete(url, headers: {"content-type" => "application/json"}, 
                         parameters:{:vhost=>"/#{vhost}",:name=>"#{name}",:mode=>"purge"}.to_json, 
                         auth:{:user=>"#{@username}", :password=>"#{@password}"}
                        )
    pp res.code
  end

  def report_vp_cluster_status
    url = @url+"queues?sort=messages_ready&sort_reverse=true"
    res = Unirest.get(url, headers: {}, 
                      parameters: nil, 
                      auth:{:user=>"#{@username}", :password=>"#{@password}"}
                     )
    failed_queues = {}
    res.body.each {|r|
      if r["name"].include? "mr_to_vp_partitionedevent_"
        if r["consumers"] != 1 
          failed_queues[ r["name"] ] = r["consumers"]
        end 
      end
    }
    if  failed_queues.empty?
      puts "Success, all mr_to_vp_partitionedevent queues have exactly 1 consumer."
      exit 0
    else
      puts "FAILED, queues with consumers != 1"
      failed_queues.each do |key,value| puts "#{key} : #{value}" end
      exit 1
    end
  end
end
