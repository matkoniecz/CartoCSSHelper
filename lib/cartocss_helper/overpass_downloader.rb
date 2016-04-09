require 'rest-client'

module CartoCSSHelper
  class OverpassDownloader
    class OverpassRefusedResponse < IOError; end

    def self.run_overpass_query(query, description, retry_count=0, retry_max=5)
      start = Time.now.to_s
      begin
        url = OverpassDownloader.format_query_into_url(query)
        timeout = OverpassDownloader.get_allowed_timeout_in_seconds
        return RestClient::Request.execute(:method => :get, :url => url, :timeout => timeout)
      rescue RestClient::RequestTimeout => e
        puts 'Overpass API refused to process this request. It will be not attempted again, most likely query is too complex. It is also possible that Overpass servers are unavailable'
        puts
        puts query
        puts
        puts url
        puts
        puts e
        raise OverpassRefusedResponse
      rescue RestClient::RequestFailed, RestClient::ServerBrokeConnection => e
        puts query
        puts
        puts url
        puts
        puts e
        puts e.response
        puts e.http_code
        puts start
        puts "Rerunning #{description} started at #{Time.now.to_s} (#{retry_count}/#{retry_max}) after #{e}"
        if retry_count < retry_max
          sleep 60*5
          OverpassDownloader.run_overpass_query(query, description, retry_count+1, retry_max)
        else
          e.raise
        end
      rescue ArgumentError => e
        puts 'ArgumentError from rest-client, most likely caused by https://github.com/rest-client/rest-client/issues/359'
        puts 'try overpass query that will return smaller amount of data'
        puts e
        e.raise
      rescue => e
        puts 'query failed'
        puts query
        puts
        puts url
        puts e
        e.raise
      end
    end

    def self.get_allowed_timeout_in_seconds
      return 10 * 60
    end

    def self.format_query_into_url(query)
      query = query.gsub(/\n/, '')
      query = query.gsub(/\t/, '')
      base_overpass_url = OverpassDownloader.get_overpass_instance_url
      return base_overpass_url + '/interpreter?data=' + URI.escape(query)
    end

    def self.get_overpass_instance_url
      return CartoCSSHelper::Configuration.get_overpass_instance_url
    end
  end
end
