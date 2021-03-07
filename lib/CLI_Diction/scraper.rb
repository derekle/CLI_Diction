class Diction::Scraper
    ### Contains functions for interacting with Datamuse's API
    @@queryresults = nil
    def isword?(input)
        ### Handles determining if the inputted text is actually a word

        ### Retrieve words that are spelled like inputted text
        @queryresults = Datamuse.words(sp: "#{input}")
        
        results = Array.new
        ### Remove score key from API results
        @queryresults.each do |x|
            results << x.fetch_values("word")
            results.flatten!(1)
        end

        ### See if the list of similarly spelled words contain an exact match
        results.find(input)

        if results.find{|word| word == input} == nil
        ### If none, create a list of additional suggestions ontop of the current list of results
            results << getSuggestions(input)
            results.flatten!(1)
            ### If there are no results return false (the text is not a word)
            if results.length == 0
                return false
            ### Print suggested results via CLI
            else
                Diction::CLI.new.print_suggested(results)
            end
        else
            ### If there is a result return true (the text is a word)
            results.include?(input)
        end
    end
    
    def getSuggestions(input)
        ### Handles creating a list of suggested results by combining a list of words that sound like the text and the API's algorithm
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