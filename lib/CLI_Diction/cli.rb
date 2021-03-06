class Diction::CLI
    @@inputtxt = nil

    def call
        puts "========================"
        puts "//// CLI DICTION APP ////"
        start
    end

    def start
        puts "========================"
        puts "=== Please enter your query: ==="
        puts "(Press 0 to exit application.)"
        puts "========================"

        @@inputtxt = gets.delete_suffix!("\n").downcase
        list_process
        puts "Processing..."
        sleep 1
    end


    def list_process
        if numcheck? == true
            if @@inputtxt.to_i == 0
                puts "Exiting..."
                sleep 1
                exit
            elsif @@inputtxt.to_i == 1
                Diction::App.all.each do |x|
                    p x.text
                end
                start
            else
                puts "Cannot parse input. Please enter a valid text."
                start
            end
        elsif alphacheck? == false
            puts "No letters detected. Cannot parse input. Please enter a valid text."
            list_process
        else
            @@inputtxt.split(" ").uniq.each do |text|
                Diction::App.new_from_input(text)
            end

            case sentence?
                when 1

                    puts "What would you like to do?"
                    puts "1. Spellcheck"
                    puts "2. Return"
                    puts "3. Exit"
                    listinput = gets.to_i
                    if listinput == 1
                        print_spellcheck
                    elsif listinput == 2
                        puts "Returning..."
                        sleep 1
                        start
                    elsif listinput == 3
                        puts "Exiting..."
                        sleep 1
                        exit
                    else
                        puts "Please enter a valid command."
                        list_process(@@inputtxt)
                    end

                when 2
                        puts "What would you like to do?"
                        puts "1. Dictionary"
                        puts "2. Thesaurus"
                        puts "3. Return"
                        puts "4. Exit"
                        listinput = gets.to_i
                        if listinput == 1
                            print_dictionary
                        elsif listinput == 2
                            print_thesaurus
                        elsif listinput == 3
                            puts "Returning..."
                            sleep 1
                            start
                        elsif listinput == 4
                            puts "Exiting..."
                            sleep 1
                            exit
                        else
                            puts "Please enter a valid command."
                            list_process(@@inputtxt)
                        end

                when 3
                    puts "Please enter a valid input."
                    start
            end
        end
    end

    def menuReturn
        if gets.to_i == 0
            puts "Returning..."
            sleep (1)
            start
        end
    end

    def isword?
        Diction::Scraper.new.isword?(@@inputtxt)
    end

    def alphacheck?(input = @@inputtxt)
        input.match?(/[[:alpha:]]/)
    end

    def numcheck?(input = @@inputtxt)
        input.match?(/[[:digit:]]/)
    end
    
    def sentence?(input = @@inputtxt)
        if input.split(" ").length > 1
            puts "========================"
            puts "Sentence detected!"
            return 1

        elsif input.split(" ").length == 1
            if isword? == true
                puts "========================"
                puts "Word detected!"
                return 2
            else isword? == false
                puts "========================"
                puts "Nothing detected!"
                return 3
            end

        else input.split(" ").length == 0
            puts "========================"
            puts "Nothing detected!"
            return 3
        end
    end


    def print_dictionary
        puts "========================"
        puts "Dictionary"
        text = Diction::App.find(@@inputtxt)[0]
        p "dictionary text: #{text}"
        if text.hasDef? == nil
            puts "Hm, it looks like there's no definition associated with this word."
            print_suggested(Diction::Scraper.new.getSuggestions(text.text))
        end
        if text.hasDef? == true
            defs = text.definitions[0].fetch_values("defs").flatten(1)
            defs.each.with_index do |word, index|
                word.gsub!(/n\t/, "Noun: ")
                word.gsub!(/v\t/, "Verb: ")
                word.gsub!(/adj\t/, "Adjective: ")
                puts "#{index+1}. #{word}."
            end
        end
        puts "========================"
        puts "Press 0 to return."

        menuReturn
    end

    def print_thesaurus
        puts "========================"
        puts "Thesaurus"
        text = Diction::App.new_from_input

        if text.hasSyn? == nil
            puts "Hm, it looks like there are no synonyms associated with this word."
        end
        if text.hasSyn? == true
            text.synonyms.each.with_index do |word, index|
                puts "#{index+1}. #{word.fetch_values("word")[0].capitalize}"
            end
        end
        puts "========================"
        puts "Press 0 to return."

        menuReturn
    end

    def print_spellcheck
        puts "========================"
        puts "Spellcheck."
        holdSentence = @@inputtxt.split(" ")
        wordCount = 0
        wordstoCheck = holdSentence.uniq
        while wordCount < wordstoCheck.length
            checkword = wordstoCheck[wordCount]
            text = Diction::App.find(checkword)[0]
            @text = text.text
            if text.hasDef? == nil
                fix = print_suggested(Diction::Scraper.new.getSuggestions(@text), 1, true)
                if fix == nil
                    fix = checkword
                end
                holdSentence.map!{|word| word == checkword ? fix : word}
            end
            wordCount += 1
        end
        puts "========================"
        puts holdSentence.join(" ")
        puts "Press 0 to return"
        menuReturn
    end

    def gets_page(input, pageNum)
       
        #ap parse
        pgtoindx = pageNum-1
        input[pgtoindx].each.with_index do |x, y|
            puts "#{(pgtoindx*10)+(y+1)}. #{x}"
        end
    end

    def print_suggested(input, pageNum = 1, scFlag = false)
        puts "========================"
        flag = scFlag
        if scFlag == true
            puts "Here are a list of suggested spellings for [#{@text}]. Navigate with left and right arrow keys. Press 0 to return to main menu."
        end
        if scFlag == false
            puts "Here are a list of suggested spellings for [#{@@inputtxt}]. Navigate with left and right arrow keys. Press 0 to return to main menu."
        end
        parse = input.each_slice(10).to_a
        gets_page(parse, pageNum)


        inputtxt = gets.delete_suffix!("\n")

        if numcheck?(inputtxt) == true
            if inputtxt.to_i ==  0 && scFlag == false
                puts "Returning..."
                sleep (1)
                start
            elsif inputtxt.to_i == 0 && scFlag == true
                puts "Skipping..."
                sleep (1)
                return nil
            elsif inputtxt.to_i >= 1 && inputtxt.to_i <= input.length
                @@inputtxt = input[inputtxt.to_i-1]
                puts "Processing suggested word: #{@@inputtxt}"
                if scFlag == true
                    return @@inputtxt
                end
                if scFlag == false
                    list_process
                end
            else
                puts "Please make a valid selection."
                print_suggested(input)
            end
        elsif inputtxt == "\e[C"
            if pageNum == parse.length
                print_suggested(input, pageNum, flag)
            else
                pageNum += 1
                print_suggested(input, pageNum, flag)
            end
        elsif inputtxt == "\e[D"
            if pageNum == 1
                print_suggested(input, pageNum, flag)
            else
                pageNum -= 1
                print_suggested(input, pageNum, flag)
            end
        else alphacheck?(inputtxt) == true
            puts "Please make a valid selection."
            print_suggested(input, pageNum, flag)
        end
    end
end