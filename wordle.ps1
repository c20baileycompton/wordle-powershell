<#
WORDLE
1st Lt Bailey Compton
2nd Lt Andrew Empeno
2nd Lt Mitchell Milliken

This game asks the player to guess a five-letter word, and indicates if any letters
in the guessed word are in the goal word, and whether or not they are in the correct position.

11 July 2022
#>

function init {
    
    #Set window colors 
    $Host.UI.RawUI.BackgroundColor = "Black" 
    $Host.UI.RawUI.ForegroundColor = "White"
    
    clear-host
} 

function displayMenu([string]$title,[array]$MenuItems){
    $title = "|`t  WELCOME TO WORDLE `t`t|`n|`tHosted by`t`t`t`t`t|`n|`t1st Lt Bailey Compton`t`t|`n|`t2nd Lt Andrew Empeno`t`t|`n|`t2nd Lt Mitchell Milliken`t|"
    $MenuItems = @("|`t1. Play `t`t`t`t`t|",`
                   "`n|`t2. Instructions`t`t`t`t|",`
                   "`n|`t3. Exit Powershell`t`t`t|") -join ''
    $randomArray = @("`n+","-------------------------------","+") -join ''

    #Creating displayMenu graphic box   
    $menubox = "`n+-------------------------------+`n$title`n+-------------------------------+`n$MenuItems$randomArray `n"
    $menubox
}

function chooseMenuItem(){
#check that the chosen menu item is valid and return it
    $selection = read-host "Select [1-3]"
    while($selection -ne "1" -and $selection -ne "2" -and $selection -ne "3"){
        $selection = read-host "Invalid choice! Please enter 1, 2, or 3"
    }
    return $selection
}

Function Instructions(){
#display gameplay instructions to the user
    write-host "Instructions sequence intiating..."
    write-host ""
    write-host "Loaded:"
    write-host ""
    write-host -ForegroundColor Green "GREEN" -NoNewline; Write-Host " means that the letter is in the final word"
    write-host -ForegroundColor Yellow "YELLOW" -NoNewline; Write-Host " means that the letter is in the final word but is not in the correct spot"
    write-host -ForegroundColor Gray "GRAY" -NoNewline; Write-Host " means that the letter is not in the final word"
    write-host ""
    read-host "Press enter to return to menu"
    clear-host
}

function importWords(){
    #loads in valid wordlist and chooses goal word from goal wordlist
    #returns valid wordlist and goal word

    #validwords is an array of all the valid 5 letter words the user can guess
    $validwords = Get-Content(".\validwords.txt")
    $goalword = Get-Content(".\wordlist.txt") | Get-Random

    return $goalword, $validwords
}

Function Play([string]$goalword, [array]$validwords){
    #main loop for gameplay
    $wordguessed = 0
    $guesses = @()
    $colors = @()
    while(-not $wordguessed -and $guesses.Count -lt 6){
        write-host
        $guess = Read-Host "Enter your guess".Trim()

        while(-not (validGuess $guess $validwords)){
        #check that the guess is a valid word
            $guess = Read-Host "Your guess was not a valid word. Please enter a new guess".Trim()
        }

        $guesses += , $guess
        $colors += , (letterColors $guess $goalword)

        displayGame $guesses $colors

        if((correctGuess $guess $goalword)){
            $wordguessed = 1
        }
    }
    if($wordguessed){
        Write-Host "`nCongratulations! You correctly guessed the word. Come back another time!"
    }
    else{
        Write-Host "`nSorry, you didn't guess the word. The correct word was`t$goalword`t Better luck next time!"
    }
}

function validGuess([string]$guess, $validwords){
    #checks to see if the user's guess is listed as a valid word in the dictionary
    #returns true (1) if the guess is valid
    #returns false (0) if the guess is invalid

    if($guess.Length -ne 5){
        write-host "Uh-oh! Your guess must be a five-letter word."
        return 0
    }
    foreach($word in $validwords){
        if($word -eq $guess){
            return 1
        }
    }
    return 0
}

function correctGuess([string]$guess, [string]$goalword){
    #checks to see if the user's guess is the goal word
    #returns true (1) if the user has guessed the word
    #returns false (0) if the user has not guessed the word

    if($guess -eq $goalword){
        return 1
    }
    else{
        return 0
    }
}

function letterColors([string]$guess, [string]$goal){
    #TODO: if there are multiple of a letter in a guess and that letter is in the goal word, all letters will appear yellow
    $colors = @()

    for($i=0;$i -lt 5;$i++){
        if($goal.Contains($guess[$i])){
            if($goal[$i] -eq $guess[$i]){
                $colors += , "GREEN"
            }else{
                 $colors += , "YELLOW"
            }
        }else{
            $colors += , "GRAY"
        }
    }

    # write-host $colors
    return $colors
}

function displayGame([array]$guesses, [array]$colors){
    #guesses is an array of strings, with each item being a guessed word
    #colors is an array, with each item being an array of strings denoting a color

    for($guessnum = 0;$guessnum -lt $guesses.Count;$guessnum++){
    #loop through all entered guesses
        [string]$word = $guesses[$guessnum]
        [array]$wordcolors = $colors[$guessnum]
        for($letternum = 0;$letternum -lt 5;$letternum++){
        #loop through all letters in the current guess
            $letter = $word[$letternum]
            [string]$color = $wordcolors[$letternum]
            # $color will either be "GREEN", "YELLOW", or "GRAY"
            switch($color){
                "GREEN"{write-host -ForegroundColor Green $letter -NoNewline}
                "YELLOW"{write-host -ForegroundColor Yellow $letter -NoNewline}
                "GRAY"{write-host -ForegroundColor Gray $letter -NoNewline}
            }
        }
        write-host
    }
}

function goodbye(){
    #displays a goodbye message to the user
    read-host "`nThank you for playing. Press enter to exit"
    write-host "Goodbye! Closing game..."
    Start-Sleep -s 2
    Exit
}

function main(){
    $goal, $valid = importWords
    init
    do{
        displayMenu
        $menuChoice = chooseMenuItem
        if($menuChoice -eq "2"){
            Instructions
        }if($menuChoice -eq "3"){
            Exit
        }
    }while($menuChoice -ne "1")
    Play $goal $valid
    goodbye
}

main