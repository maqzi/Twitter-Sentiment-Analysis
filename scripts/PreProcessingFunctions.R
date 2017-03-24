RemStopWords<- function(text){
  stopWordsFinal <- read.table("stopwordslists/completeListStopWords.txt")
  text = removeWords(text, c(unlist(stopWordsFinal), "melania" ,"barack", "obama", "hilary", "clinton","african","american","mexican","men","women","muslim","christian","nazi","indian","china","syria","isis"))
  return(text)  
}

PreProcess <- function(some_txt){
  some_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)<>", "", as.matrix(some_txt))
  some_txt = gsub("@\\w+", "", some_txt)
  some_txt = gsub("[[:punct:]]", "", some_txt)
  some_txt = gsub("[[:digit:]]", "", some_txt)
  some_txt = gsub("http\\w+", "", some_txt)
  some_txt = gsub("[ \t]{2,}", "", some_txt)
  some_txt = gsub("^\\s+|\\s+$", "", some_txt)
  some_txt = as.matrix(toLower(some_txt))
  some_txt = as.matrix(some_txt[!is.na(some_txt)])
  names(some_txt) = NULL
  return(some_txt)
}