class ApiRequest

  require 'net/http'
  #require 'rexml/document'
  

  attr_reader :response, :result

  def initialize(uid, pw, url='http://resellertest.enom.com')
    page  = '/interface.asp'
    query = '?UID=' + uid.to_s + '&PW=' + pw.to_s
    @uri = URI.parse(url + page + query)
  end

  # Method to check for availability of domains.
  # Can be used by providing one sld as a string
  # and tlds as a string or array of mulitple tlds.
  # Alternatively, an array of fully qualified
  # domains can be provided as the first argument
  # (the second arg must be dropped in that case).
  # Returns an array of domains with a boolean or nil
  # result - true = available, false = not available,
  # nil = no result/problem
  def check_domains(sld_or_domains, tlds=nil)
    query_args = {'Command' => 'Check'}
    if sld_or_domains.is_a? Array
      query_args['DomainList'] = sld_or_domains.join(',')
    else
      query_args['SLD'] = sld_or_domains
    end
    unless tlds == nil
      if tlds.is_a? Array
        query_args['TLDList'] = tlds.join(',')
      else
        query_args['TLD'] = tlds
      end
    end
    query_push(query_args)
    get_response
    # Set up a hash of domains
    checked_domains = {}
    if query_args['DomainList']
      sld_or_domains.each {|domain| checked_domains[domain] = nil}
    elsif query_args['TLDList']
      tlds.each {|tld| checked_domains[sld_or_domains + '.' + tld] = nil}
    else
      checked_domains[sld_or_domains + '.' + tlds] = nil
    end
    # RRPCodes: 210 = available, 211 = not available
    if checked_domains.length > 1
      # If we have multiple domains, run a loop to fill in results
      x = 1
      @result['DomainCount'].to_i.times do
        domain = @result['Domain' + x.to_s]
        if @result['RRPCode' + x.to_s].to_i == 210
          checked_domains[domain] = true
        elsif @result['RRPCode' + x.to_s].to_i == 211
          checked_domains[domain] = false
        end
        x += 1
      end
    else
      if @result['RRPCode'].to_i == 210
        checked_domains[sld_or_domains + '.' + tlds] = true
      elsif @result['RRPCode'].to_i == 211
        checked_domains[sld_or_domains + '.' + tlds] = false
      end
    end
    puts checked_domains.to_yaml
  end

  # Method to get the domain count.
  def get_domain_count
    query_push 'Command' => 'GetDomainCount'
    get_response
  end
  
  # Method to get the information for a given domain.
  def get_domain_info(sld, tld)
    query_push 'Command' => 'GetDomainInfo', 'SLD' => sld, 'TLD'=> tld
    get_response
  end

  # Method to register a domain. Provide the sld & the tld.
  # Optionally provide extra_info :admin => Contact object
  # - this will be used as the admin contact details
  # Optionally provide extra_info :nameservers => array of nameserver names
  def register_domain(sld, tld, *extra_info)
    query_push({'Command' => 'Purchase', 'SLD' => sld, 'TLD' => tld,
                'Debit' => 'True'})
    if extra_info[:admin]
      if extra_info[:admin].is_a? Contact
        query_push {}
      end
    end

    if extra_info[:nameservers]
      query_push {}
    else
      query_push {'UseDNS' => 'default'}
    end

    get_response
    if @result['RRPCode'].to_i == 200
      return true
    else
      return false
    end
  end

  def to_s
    puts "Query string:"
    puts @uri.query
    puts "============="
    puts "Response body:"
    puts @response.body
    puts "============="
    #puts "XML object root:"
    #root = @xml.root
    #puts root
    #puts "============="
  end

  private
  # Method to make the call to the eNom API and parse
  # the response.
  def get_response
    @response = Net::HTTP.get_response @uri
    # Parse the response body
    response_array = @response.body.split
    @result = {}
    response_array.each do |val|
      # Strip newlines
      val.gsub! /\r\n$/, ''
      # If val is not a comment (beginning with ';'),
      # split it on the '=' and add it to the @result
      # hash.
      unless val =~ /^;/
        #x = val.split('=')
        @result.store(val.split('=')[0], val.split('=')[1])
      end
    end
    @result
  end

  def query_push(query_hash)
    query_hash.each do |key, val|
      @uri.query << '&' << key << '=' << val
    end
  end
end
