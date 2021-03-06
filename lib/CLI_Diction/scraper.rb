class Diction::Scraper
    @@queryresults = nil
    def isword?(input)
        query(input)
        
        results = Array.new
        @queryresults.each do |x|
            results << x.fetch_values("word")
            results.flatten!(1)
        end

        results.find(input)

        if results.find{|word| word == input} == nil
            results << getSuggestions(input)
            results.flatten!(1)
            if results.length == 0
                return false
            else
                Diction::CLI.new.print_suggested(results)
            end
        else
            results.include?(input)
        end
    end

    def query(input)
        @queryresults = Datamuse.words(sp: "#{input}")
    end
    
    def getSuggestions(input)
        output = Array.new
        soundsLikeResults = Datamuse.words(sl: "#{input}")
        suggResults = Datamuse.sug(s: "#{input}")

        soundsLikeResults.each do |x|
            output << x.fetch_values("word")
            output.flatten!(1)
        end
        suggResults.each do |x|
            output << x.fetch_values("word")
            output.flatten!(1)
        end
        
        return output
    end
end