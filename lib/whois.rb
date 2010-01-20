# Whois module - enables WHOIS queries, uses a cache to stop multiple
# WHOIS queries being made if the domain in question has just been queried.

module Whois

  # Method to return listed nameservers.
  def listed_nameservers(domain=nil)
    begin
      domain = self.fqdn if domain == nil
    rescue NoMethodError
      raise ArgumentError, "wrong number of arguments (0 for 1)"
    end
    @whois = parse_query(domain)
    nameservers = @whois['nameservers']
  end

  # Method to check the domain registration status.
  def check_status(domain=nil)
    begin
      domain = self.fqdn if domain == nil
    rescue NoMethodError
      raise ArgumentError, "wrong number of arguments (0 for 1)"
    end
    @whois = parse_query(domain)
    @whois['status']
  end
  
  # Method to run the whois program with the domain and parse the
  # output into a hash
  def parse_query(domain=nil)
    domain_file = "tmp/#{domain}_whois"
    #puts("DEBUG >>> whois/parse_query called on domain #{domain}. Cache file will be stored in #{domain_file}")
    begin
      domain = self.fqdn if domain == nil
    rescue NoMethodError
      raise ArgumentError, "wrong number of arguments (0 for 1)"
    end
    if domain_is_cached(domain)
      #puts("DEBUG >>> #{domain} is already cached, getting results from file.")
      # If we have a valid cached file, we load that up and use it.
      @whois = File.open(domain_file) {|f| Marshal.load(f)}
    else
      # We only actually run a WHOIS query if the domain is not cached - so we
      # don't access WHOIS services too much.
      #puts("DEBUG >>> #{domain} is not cached, making whois system call.")
      whois_output = `whois -H #{domain} 2> /dev/null`
      # Check that the whois query worked
      if $?.exitstatus > 0
        raise "WHOIS query was not successful - possible network error?"
      end
      # See how we should parse the output based on the TLD
      case domain.split('.')[-1]
      when 'biz'
        #puts("DEBUG >>> .biz TLD. Using biz_parser")
        biz_parser(whois_output)
      when 'com'
        #puts("DEBUG >>> .com TLD. Using com_parser")
        com_parser(whois_output)
      when 'info'
        #puts("DEBUG >>> .info TLD. Using info_parser")
        info_parser(whois_output)
      when 'net'
        #puts("DEBUG >>> .net TLD. Using net_parser")
        net_parser(whois_output)
      when 'org'
        #puts("DEBUG >>> .org TLD. Using org_parser")
        org_parser(whois_output)
      when 'uk'
        #puts("DEBUG >>> .uk TLD. Using uk_parser")
        uk_parser(whois_output)
      else
        raise "This TLD (.#{domain.split('.')[-1]}) has no parser in Whois module."
      end
      # Marshal dump the @whois hash to a file
      #puts("DEBUG >>> Writing the whois query results to cache file.")
      File.open(domain_file, 'w') do |f|
        Marshal.dump(@whois, f)
      end
      @whois
    end
  end
  alias whois parse_query

  private
  # Private method to see if we have a relevant cached query.
  def domain_is_cached(domain)
    domain_file = "tmp/#{domain}_whois"
    if File.file?(domain_file)
      if File.mtime(domain_file).to_time < 3.hours.ago
        # Cached result file is too old
        return false
      else
        return true
      end
    else
      return false
    end
  end

  def uk_parser(whois_string)
    # We want to parse the whois data into a hash.
    whois_hash = {}
    #puts("DEBUG >>> Putting whois data into hash")
    output_array = []
    whois_string.each_line do |l|
      output_array << l.to_s.strip
    end
    # Get the Registrant details - we are relying on this format never changing!
    #puts("DEBUG >>> Looping through the array...")
    output_array.each_index do |x|
      # We need to do some regex searching to fill our hash.
      case output_array[x]
      when /^Domain name:$/
        #puts("DEBUG >>> Found the domain name. Adding to hash.")
        whois_hash['domain'] = output_array[x+1]
      when /^Registrant:$/
        #puts("DEBUG >>> Found the registrant. Adding to hash.")
        whois_hash['registrant'] = output_array[x+1]
      when /^Registrant type:$/
        #puts("DEBUG >>> Found the registrant type. Adding to hash.")
        whois_hash['registrant_type'] = output_array[x+1]
      when /^Registrant's address:$/
        #puts("DEBUG >>> Found a registrant address line. Adding to hash.")
        whois_hash['registrant_address'] = 
          get_address(output_array, x+1, /^Registrant's agent:$/)
      when /^Administrative contact's address:$/
        #puts("DEBUG >>> Found an admin contact address line. Adding to hash.")
        whois_hash['admin_contact_address'] = 
          get_address(output_array, x+1, /^(Registrant's agent:|Registrar:)$/)
      when /^(Registrant's agent:|Registrar:)$/
        #puts("DEBUG >>> Found the registrant agent. Adding to hash.")
        whois_hash['registrant_agent'] = [output_array[x+1], output_array[x+2]]
      when /^Relevant dates:$/
        #puts("DEBUG >>> Found relevant dates. Parsing...")
        # We will be able to get registration date, renewal date and last updated date
        whois_hash['registration_date'] = output_array[x+1].split[-1].to_date
        #puts("DEBUG >>> Added reg date to hash.")
        whois_hash['renewal_date']      = output_array[x+2].split[-1].to_date
        #puts("DEBUG >>> Added renewal date to hash.")
        whois_hash['last_updated']      = output_array[x+3].split[-1].to_date unless output_array[x+3].blank?
        #puts("DEBUG >>> Added last updated date to hash.")
      when /^Registration status:$/
        whois_hash['status'] = output_array[x+1]
      when /^Name servers:$/
        #puts("DEBUG >>> Found the name servers. Adding to hash.")
        whois_hash['nameservers'] = []
        # Now loop through the output_array until we hit "WHOIS lookup made...",
        # to get the other possible address lines.
        ctr = x + 1
        ns_ctr = 0
        while output_array[ctr] !~ /^WHOIS lookup made at/
          whois_hash['nameservers'][ns_ctr] = output_array[ctr] unless output_array[ctr].blank?
          ctr += 1
          ns_ctr += 1
        end
      end
    end
    # Add 'Nominet' in as the registrar (as long as other data has been added).
    whois_hash['registrar'] = 'Nominet' unless whois_hash.blank?
    @whois = whois_hash
  end

  def com_parser(whois_string)
    # We want to parse the whois data into a hash.
    whois_hash = {}
    # Put our whois_string into an array.
    output_array = []
    whois_string.each_line do |l|
      output_array << l.to_s.strip
    end
    # Go through the output array and put data into our whois_hash.
    output_array.each_index do |x|
      # Do regex searching via case statements on each index.
      case output_array[x]
      when /^Domain Name:/
        whois_hash['domain'] = output_array[x].split[-1].downcase
      when /^Registrar:/
        whois_hash['registrar'] = $'.strip # $' is the string following the match just made.
      when /^Name Server:/
        whois_hash['nameservers'] = [] if whois_hash['nameservers'].blank?
        whois_hash['nameservers'] << $'.strip.downcase
      when /^Status:/
        whois_hash['status'] = [] if whois_hash['status'].blank?
        whois_hash['status'] << $'.strip
      when /^Updated Date:/
        whois_hash['last_updated'] = $'.strip.to_date
      when /^Creation Date:/
        whois_hash['registration_date'] = $'.strip.to_date
      when /^Expiration Date:/
        whois_hash['renewal_date'] = $'.strip.to_date
      when /^Registrant Contact:$/
        whois_hash['registrant_address'] =
          get_address(output_array, x+1)
      when /^Administrative Contact:$/
        #whois_hash['admin_contact'] = output_array[x+1].split[0..-2].join
        #whois_hash['admin_contact_email'] = output_array[x+1].split[-1]
        whois_hash['admin_contact_address'] = 
          get_address(output_array, x+1)
      when /^Technical Contact:$/
        #whois_hash['tech_contact'] = output_array[x+1].split[0..-2].join
        #whois_hash['tech_contact_email'] = output_array[x+1].split[-1]
        whois_hash['tech_contact_address'] =
          get_address(output_array, x+1)
      end
    end
    @whois = whois_hash
  end
  alias net_parser com_parser

  def info_parser(whois_string)
    whois_hash = {}
    # We need to create address arrays in the whois_hash
    whois_hash['registrant_address'] = []
    whois_hash['admin_contact_address'] = []
    whois_hash['billing_contact_address'] = []
    whois_hash['tech_contact_address'] = []
    # Put our whois_string into an array.
    output_array = []
    whois_string.each_line do |l|
      output_array << l.to_s.strip
    end
    # Go through the output array and put data into our whois_hash.
    output_array.each_index do |x|
      case output_array[x]
      when /^Domain Name:/
        whois_hash['domain'] = $'.downcase.strip
      when /^Sponsoring Registrar:/
        whois_hash['registrar'] = $'
      when /^Status:/
        whois_hash['status'] = [] if whois_hash['status'].blank?
        whois_hash['status'] << $'.strip
      when /^Domain Status:/
        whois_hash['status'] = $'.strip
      when /^Registrant Name:/
        whois_hash['registrant'] = $'.strip
      when /^Registrant Email:/
        whois_hash['registrant_email'] = $'.strip
      when /^Registrant Organization:/
        whois_hash['registrant_address'] << $'.strip
      when /^Registrant (Address1|Address2|City|State\/Province|Postal Code|Country|Country Code):/
        whois_hash['registrant_address'] << $'.strip
      when /^Administrative Contact Name:/
        whois_hash['admin_contact'] = $'.strip
      when /^Administrative Contact (Organization|Address1|Address2|City|State\/Province|Postal Code|Country|Country Code|Phone Number):/
        whois_hash['admin_contact_address'] << $'.strip
      when /^Administrative Contact Email:/
        whois_hash['admin_contact_email'] = $'.strip
      when /^Billing Contact Name:/
        whois_hash['billing_contact'] = $'.strip
      when /^Billing Contact (Organization|Address1|Address2|City|State\/Province|Postal Code|Country|Country Code|Phone Number):/
        whois_hash['billing_contact_address'] << $'.strip
      when /^Billing Contact Email:/
        whois_hash['billing_contact_email'] = $'.strip
      when /^Technical Contact Name:/
        whois_hash['tech_contact'] = $'.strip
      when /^Technical Contact (Organization|Address1|Address2|City|State\/Province|Postal Code|Country|Country Code|Phone Number):/
        whois_hash['tech_contact_address'] << $'.strip
      when /^Technical Contact Email:/
        whois_hash['tech_contact_email'] = $'.strip
      when /^Domain Registration Date:/, /^Created On:/
        whois_hash['registration_date'] = $'.strip.to_date
      when /^Domain Expiration Date:/, /^Expiration Date:/
        whois_hash['renewal_date'] = $'.strip.to_date
      when /^Domain Last Updated Date:/, /^Last Updated On:/
        whois_hash['last_updated'] = $'.strip.to_date
      when /^Name Server:/
        whois_hash['nameservers'] = [] if whois_hash['nameservers'].blank?
        whois_hash['nameservers'] << $'.strip.downcase unless $'.blank?
      end
    end
    @whois = whois_hash
  end
  alias biz_parser info_parser
  alias org_parser info_parser

  def get_address(whois_array, starting_index, end_pattern=nil)
    ctr = starting_index
    add_ctr = 0
    address = []
    # Loop through the whois output array from the start point until the end pattern.
    if end_pattern == nil
      while !whois_array[ctr].blank?
        address[add_ctr] = whois_array[ctr]
        add_ctr += 1
        ctr += 1
      end
    else
      while whois_array[ctr] !~ end_pattern && whois_array[ctr] !~ /[:whitespace:]/
        address[add_ctr] = whois_array[ctr] 
        add_ctr += 1
        ctr += 1
      end
    end
    address
  end

end
