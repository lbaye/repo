require 'net/http'
require 'uri'
require 'benchmark'

class ApiBenchmark < Thor

  desc 'benchmark HTTP_METHOD URL HEADERS PARAMS TIMES', 'Benchmark SM search'

  def benchmark(method, url, str_headers = '', str_params = '', times = 1)
    puts "Creating #{method} request with #{url}"
    headers = convert_to_hash str_headers
    params  = convert_to_hash str_params

    puts "Executing benchmarking for #{times} times"

    Benchmark.bm do |x|
      times.to_i.times.each do |i|
        x.report("Req##{i}") {
          response = create_request method, url, headers, params
          puts "  Response code - #{response.code}"
        }
      end
    end

  end

  private
  def create_request(method, url, headers, params)
    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    case method.upcase.to_sym
      when :GET
        path    = "#{uri.request_uri}?#{params.map { |k, v| "#{k}=#{CGI.escape(v)}" }.join('&')}"
        request = Net::HTTP::Get.new(path, headers)
        http.request(request)

      when :POST
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.set_form_data(params)
        http.request(request)

      when :PUT
        request = Net::HTTP::Put.new(uri.request_uri, headers)
        request.set_form_data(params)
        http.request(request)

      when :DELETE
        path    = "#{uri.request_uri}?#{params.map { |k, v| "#{k}=#{CGI.escape(v)}" }.join('&')}"
        request = Net::HTTP::Delete.new(path, headers)
        http.request(request)

      else
        nil
    end
  end

  def convert_to_hash(str)
    { }.tap do |hash|
      if str.to_s.length > 0
        str.split('|').collect { |line|
          line.split(':').
              tap { |parts| hash[parts.first.strip] = parts.last.strip }
        }
      end
    end
  end

end