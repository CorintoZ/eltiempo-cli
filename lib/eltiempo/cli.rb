require "thor"
require "nokogiri"
require "open-uri"

module Eltiempo
  class WeatherCLI < Thor

    desc "today LOCALIDAD","Returns the actual temperature"
    
    def today(location)
      calculateTemperature(location, 0)  
    end

    desc "av_max LOCALIDAD","Returns the average maximum temperature during the week"
    
    def av_max(location)
      calculateTemperature(location, 1) 
    end

    desc "av_min LOCALIDAD","Returns the average minimum temperature during the week"
    
    def av_min(location)
      calculateTemperature(location, 2)
    end

    def self.start(args)
      args[0] = args[0].sub("-", "") unless args[ 0 ].nil?
      super(args)
    end

    def self.exit_on_failure?
      true
    end

    private
    def calculateTemperature(location, option)
      townData = getTownData(location)
            
      case option
      when 0
        min = townData.xpath("//location//var[1]//data//forecast[1]/@value").to_s
        max = townData.xpath("//location//var[2]//data//forecast[1]/@value").to_s
        temperature = (Integer(min)+Integer(max))/2
        puts "The temperature for today in #{location} is around #{temperature}ºC"
      when 1
        forecast_a = townData.xpath("//location//var[2]//data//forecast//@value").to_a
        max = forecast_a.reduce(0) { |sum, num| sum + Integer(num.value) } / 7
        puts "The average maximum temperature in #{location} during this week is #{max}ºC"    
      when 2
        forecast_a = townData.xpath("//location//var[1]//data//forecast//@value").to_a
        min = forecast_a.reduce(0) { |sum, num| sum + Integer(num.value) } / 7
        puts "The average minimum temperature in #{location} during this week is #{min}ºC"  
      end
    end

    def getTownData(location)
      town_list = Nokogiri::XML(URI.open('http://api.tiempo.com/index.php?api_lang=es&division=102&affiliate_id=zdo2c683olan')) 
      code = String(town_list.xpath("//data//name[text()='#{location}']/@id"))

      if(code.empty?)
        abort "The town #{location} is not available or doesn't exist"
      end
      
      url = "http://api.tiempo.com/index.php?api_lang=es&localidad=#{code}&affiliate_id=zdo2c683olan"
      data = Nokogiri::XML(URI.open(url))
    end
  end
end
