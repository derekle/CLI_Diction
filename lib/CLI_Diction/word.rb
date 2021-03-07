class Diction::Word < Diction::CLI
    ### Contains functions for retrieving the word's attributes
    attr_accessor :text, :definitions, :synonyms

    @@all = []

    def self.new_from_input(input = @@inputtxt)
        ### Check if an object already exists for the inputted word. Return that object's instance if true instead of making a new one.
        matches = self.find(input)
        if matches.length > 0
            return matches[0]
        else
            self.new(input)
        end
    end

    def initialize(input)
        @definition = nil
        @synonyms = nil
        @text = input
        @@all << self
    end

    def self.all
        @@all
    end

    def self.find(input)
        self.all.find_all{|word| word.text == "#{input}"}
    end

    def checkkey
        ### Check if the word has a definition associated with it
        @definitions.each do |x|
            return x.has_key?("defs")
        end
    end

    def hasDef?
        ### Handles retrieval of the word's definitions
        @definitions ||= Datamuse.words(sp: "#{@text}", md: "d")
        if checkkey == true
            return true
        else
            return nil
        end
    end

    def hasSyn?
        ### Handles retrieval of the word's synonyms
        @synonyms ||= Datamuse.words(rel_syn:"#{@text}")
        if @synonyms.empty? == true
            return nil
        else
            return true
        end
    end
end

