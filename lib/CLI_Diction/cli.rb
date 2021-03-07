class Diction::CLI
    ### Contains fuctions for handling user input and navigating the terminal menus
    @@inputtxt = nil

    def call
        ### Print greeting message
        puts "========================"
        puts "//// CLI DICTION APP ////"
        start
    end

    def start
        ### Print greeting message ask for user text input
        puts "========================"
        puts "=== Please enter a word or sentence: ==="
        puts "(Press 0 to exit application.)"
        puts "========================"

        ### Saves the user's input for the current session and begin the list_process
        @@inputtxt = gets.delete_suffix!("\n").downcase
        list_process
        puts "Processing..."
        sleep 1
    end


    def list_process
        ### Processes the users' input and returns menus based on results

        ### Check if the user's input is valid
        if numcheck? == true
            if @@inputtxt.to_i == 0
                puts "Exiting..."
                sleep 1
                exit
            ### Hidden debug option which returns each word that has been instantiated into an object
            elsif @@inputtxt.to_i == 1
                Diction::Word.all.each do |x|
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

        ### If the user's input is a valid word or sentence run the following
        else
            ### Create new objects from each unique word from the user's input
            @@inputtxt.split(" ").uniq.each do |text|
                Diction::Word.new_from_input(text)
            end

            ### Return menus based on if the user is querying a sentence or a word
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
        ### Contains the script to return to the main menu if the user types 0
        if gets.to_i == 0
            puts "Returning..."
            sleep (1)
            start
        end
    end

    def isword?
        ### Calls the scraper class to check Datamuse's API for matching text in its database
        Diction::Scraper.new.isword?(@@inputtxt)
    end

    def alphacheck?(input = @@inputtxt)
        ### Checks if the user's input contains letters
        input.match?(/[[:alpha:]]/)
    end

    def numcheck?(input = @@inputtxt)
        ### Checks if the user's input contains numbers
        input.match?(/[[:digit:]]/)
    end
    
    def sentence?(input = @@inputtxt)
        ### Checks if the user's input is a sentence, word, or neither
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
        ### Handles lines related to the Dictionary option
        puts "========================"
        puts "Dictionary"
        ### Find the object instance associated with the word
        text = Diction::Word.find(@@inputtxt)[0]
        ### Check if the word has a definition
        if text.hasDef? == nil
            ### If no definition is found, assume a misspelling and get suggested spellings 
            puts "Hm, it looks like there's no definition associated with this word."
            print_suggested(Diction::Scraper.new.getSuggestions(text.text))
        end
        if text.hasDef? == true
            ### Print a formatted list of defintions
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
        ### Handles lines related to the Thesaurus option
        puts "========================"
        puts "Thesaurus"
        ### Find the object instance associated with the word
        text = Diction::Word.find(@@inputtxt)[0]
        ### Check if the word has any synonyms
        if text.hasSyn? == nil
            puts "Hm, it looks like there are no synonyms associated with this word."
        end
        if text.hasSyn? == true
            ### Print a formatted list of synonyms
            text.synonyms.each.with_index do |word, index|
                puts "#{index+1}. #{word.fetch_values("word")[0].capitalize}"
            end
        end
        puts "========================"
        puts "Press 0 to return."

        menuReturn
    end

    def print_spellcheck
        ### Handles lines related to the Spellchecking option
        puts "========================"
        puts "Spellcheck."
        ### Split the user's input into an array of individual words
        holdSentence = @@inputtxt.split(" ")
        wordCount = 0
        ### Remove duplicate words to avoid querying twice. Create an array of each unique word to process
        wordstoCheck = holdSentence.uniq
        while wordCount < wordstoCheck.length
            ### Store the current word being checked
            @text = wordstoCheck[wordCount]
            ### Find the object instance associated with the word
            text = Diction::Word.find(@text)[0]
            ### Check if the word has a definition
            if text.hasDef? == nil
                ### If no definition is found, assume a misspelling and get suggested spellings 
                fix = print_suggested(Diction::Scraper.new.getSuggestions(@text), 1, true)
                if fix == nil
                ### Leave the word alone
                    fix = checkword
                end
                ### Replace the incorrect word with the corrected spelling
                holdSentence.map!{|word| word == @text ? fix : word}
            end
            wordCount += 1
        end
        puts "========================"
        ### Return corrected sentence
        puts holdSentence.join(" ")
        puts "Press 0 to return"
        menuReturn
    end

    def gets_page(input, pageNum)
        ### Handles the retrieval and printing of each page in a list
        #ap parse
        pgtoindx = pageNum-1
        input[pgtoindx].each.with_index do |x, y|
            puts "#{(pgtoindx*10)+(y+1)}. #{x}"
        end
    end

    def print_suggested(input, pageNum = 1, scFlag = false)
        ### Handles lines related to printing a list of suggested spellings
        puts "========================"
        ### Check if the function is being called upon by the Spellchecking function
        flag = scFlag

        if scFlag == true
            puts "Here are a list of suggested spellings for [#{@text}]. Navigate with left and right arrow keys. Press 0 to return to main menu."
        end
        if scFlag == false
            puts "Here are a list of suggested spellings for [#{@@inputtxt}]. Navigate with left and right arrow keys. Press 0 to return to main menu."
        end

        ### Split suggested spelling results in to groups of 10. Each group makes up a page for the gets_page method
        parse = input.each_slice(10).to_a
        gets_page(parse, pageNum)


        inputtxt = gets.delete_suffix!("\n")
        
        ### Input check unique to this submenu
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
        ### Detects arrow keys for navigating pages of results
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