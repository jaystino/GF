--# -path=.:present

concrete PhrasebookFin of Phrasebook = 
  GreetingsFin,
  WordsFin ** open 
    SyntaxFin,
    Prelude in {

lin
  PSentence s = mkText s | lin Text (mkUtt s) ;  -- optional .
  PQuestion s = mkText s | lin Text (mkUtt s) ;  -- optional ?
  PGreeting g = mkPhrase g ;

}
