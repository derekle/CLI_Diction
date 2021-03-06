class Diction::App < Diction::CLI
    attr_accessor :text, :definitions, :synonyms

    @@all = []

    def self.new_from_input(input = @@inputtxt)
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
        @definitions.each do |x|
            return x.has_key?("defs")
        end
    end

    def hasDef?
        @definitions ||= Datamuse.words(sp: "#{@text}", md: "d")
        if checkkey == true
            true
        else
            return nil
        end
    end

    def hasSyn?
        @synonyms ||= Datamuse.words(rel_syn:"#{@text}")
        if @synonyms.empty? == true
            return nil
        else
            return true
        end
    end

    def spellcheck
        misspellings = Array.new
        @@inputtxt.each do |x|
            spellcheck?
        end
    end
end

