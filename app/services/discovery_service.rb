require "open-uri"

class DiscoveryService
  CONTENT_TYPES = [
    'application/x.atom+xml',
    'application/atom+xml',
    'application/xml',
    'text/xml',
    'application/rss+xml',
    'application/rdf+xml',
  ].freeze

  attr_reader :url
  attr_reader :variants
  attr_reader :response
  attr_reader :feeds

  def initialize(url)
    if feed?(url)
      @url   = url
      @feeds = [ url ]

    else
      uri  = URI.parse(url)
      @url = "#{ uri.scheme || 'http' }://#{ uri.host }#{ uri.path }"

      if uri.query
        @url.concat "?#{ uri.query }"
      end

      @variants = [ @url ]

      if @url.start_with? 'http://'
        https_variant = @url.gsub('http://', 'https://')
        @variants << https_variant
      end

      if ! @url.split('//').last.start_with? 'www'
        www_variant = @url.gsub('//', '//www.')
        @variants << www_variant

        if www_variant.start_with? 'http://'
          https_www_variant = www_variant.gsub('http://', 'https://')
          @variants << https_www_variant
        end
      end

      try_variants!
      parse_feeds!
      drop_feeds_with_comments!
    end
  end

  def valid_url?
    @url != false
  end

  def feed?(url)
    Feedjira::Feed.fetch_and_parse(url)
    true
  rescue
    false
  end

  def doc
    @doc ||= Nokogiri::HTML(@response)
  end

  def try_variants!
    @variants.each do |v|
      @url     = v
      @response = open_url(@url)
      if @response
        return
      end
    end
    @url = false
  end

  def open_url(url)
    open(url)
  rescue
    false
  end

  def parse_feeds!
    if ! valid_url?
      return
    end

    @feeds = []

    if doc.at('base') and doc.at('base')['href']
      @base_uri = doc.at('base')['href']
    else
      @base_uri = nil
    end

    (doc/'atom:link').each do |l|
      next unless l['rel']
      if l['type'] &&
         CONTENT_TYPES.include?(l['type'].downcase.strip) &&
         l['rel'].downcase == 'self'
        add_feed(l['href'], @url, @base_uri)
      end
    end

    (doc/'link').each do |l|
      next unless l['rel']
      if l['type'] &&
         CONTENT_TYPES.include?(l['type'].downcase.strip) &&
         (l['rel'].downcase =~ /alternate/i || l['rel'] == 'service.feed')
        add_feed(l['href'], @url, @base_uri)
      end
    end

    (doc/'a').each do |a|
      if a['href'] &&
         a['href'].include?('.feedburner.com')
        add_feed(a['href'], @url, @base_uri)
      end
    end
  end

  def add_feed(feed_url, orig_url, base_uri = nil)
    url = feed_url.sub(/^feed:/, '').strip

    if base_uri
      url = URI.parse(base_uri).merge(feed_url).to_s
    end

    begin
      uri = URI.parse(url)
    rescue
      puts "Error with `#{url}'"
      exit 1
    end

    unless uri.absolute?
      orig = URI.parse(orig_url)
      url  = orig.merge(url).to_s
    end

    if ! @feeds.include?(url)
      @feeds << url
    end
  end

  def drop_feeds_with_comments!
    if @feeds
      @feeds.select! { |url| ! url.include?('/comments/') }
    end
  end
end
