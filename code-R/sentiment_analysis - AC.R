#ML Text Analysis: This is built on the code by Daniel Ripperger-Suhler. 

#load workspace.
#load("master_workspace.RData") #make sure directory is correct.

library(rJava)
library(haven)
library(tidyverse)

#ML related.
library(tidytext)
library(topicmodels)
library(tm)
library(SnowballC)
library(tokenizers)
library(word2vec)
library(tidymodels)
library(stringr)
library(quanteda)
library(textdata)
library(widyr)

#Sentiment Analysis
lm_lexicon<-get_sentiments("loughran") #use Loughran-McDonald dictionary.
lm_negative<-get_sentiments("loughran") %>%
  filter(sentiment == "negative")

#Confirm words from Python code are in the LM lexicon.
python_words<-as_tibble(c("limit","restrict", "permit", "allow", "approve", "board")) %>%
  rename(word=value) %>%
  left_join(lm_lexicon)

python_words$sentiment[python_words$word=="allow"]<-"positive"
python_words$sentiment[python_words$word=="permit"]<-"constraining"
python_words$sentiment[python_words$word=="approve"]<-"positive"
python_words$sentiment[python_words$word=="board"]<-"neutral"
lm_lexicon<-merge(lm_lexicon,python_words,by="word",all=T)
lm_lexicon<-lm_lexicon %>%
  rename(sentiment=sentiment.x) %>%
  mutate(sentiment=coalesce(sentiment,sentiment.y))
lm_lexicon<-lm_lexicon[,1:2]

#Remove LM words from snowball stopwords.
new_stopwords<-get_stopwords(source="snowball") %>%
  anti_join(lm_lexicon) %>%
  select(word)

#Create table with word-level obs. associated with sentence, statute, and state.
#Add unnest_tokens(bigram, text, token = "ngrams", n = 2) to create an n-gram variable.

#######ADDITION

# Step 1: Subset the data to keep only "Alabama" and "California" states
subset_tbl <- tbl %>%
  filter(State %in% c("alabama", "california"))

# Step 2: Group by 'State' and filter statutes 5 to 7 in each group
# final_tbl <- subset_tbl %>%
#  group_by(State) %>%
#  slice(1:5)

# If you want to remove the grouping, you can use 'ungroup()'
#final_tbl <- final_tbl %>% ungroup()

final_tbl <- subset_tbl

##########

main_tbl<-as_tibble(final_tbl)
statute_tbl<-main_tbl %>%
  mutate(temp=tolower(text)) %>%
  mutate(temp=stringr::str_replace_all(temp,"[^a-zA-Z\\s]", " ")) %>%
  mutate(temp=stringr::str_replace_all(temp,"[\\s]+", " ")) %>%
  mutate(text=temp) %>%
  group_by(state_code) %>%
  mutate(statute=row_number()) %>%
  ungroup() %>%
  select(state_code,text,statute)

temp_tbl<-main_tbl %>%
  group_by(state_code) %>%
  mutate(statute=row_number()) %>%
  ungroup() %>%
  unnest_tokens(sentence,text,token="sentences",drop=FALSE) %>%
  group_by(state_code,statute) %>%
  mutate(sentence_no=row_number()) %>%
  ungroup() %>%
  mutate(temp=tolower(sentence)) %>%
  mutate(temp=stringr::str_replace_all(temp,"[^a-zA-Z\\s]", " ")) %>%
  mutate(temp=stringr::str_replace_all(temp,"[\\s]+", " ")) %>%
  unnest_tokens(word,temp, strip_punct=TRUE, strip_numeric=TRUE,drop=FALSE) %>%
  mutate(word=removeNumbers(word)) %>%
  anti_join(new_stopwords) %>%
  subset(nchar(as.character(word))>1) %>%
  select(state_code,statute,text,sentence_no,sentence,word) %>%
  left_join(lm_lexicon) %>% #Add lm lexicon.
  dplyr::mutate(sentiment = tidyr::replace_na(sentiment, "neutral")) %>%
  mutate(stem=wordStem(word)) #stem words.

#Create fully stemmed table.
stemmed_tbl<-temp_tbl %>% 
  group_by(state_code, statute) %>% 
  mutate(text = paste0(stem, collapse = " ")) %>%
  slice(1) %>%
  select(state_code,text,statute)

#Create asset table.
asset_tbl<-temp_tbl
asset_tbl$word[asset_tbl$word=="assets"]<-c("asset")
asset_tbl$word[asset_tbl$word=="endowments"]<-c("endowment")
asset_tbl$word[asset_tbl$word=="bonds"]<-c("bond")
asset_tbl$word[asset_tbl$word=="dissolutions"]<-c("dissolution")
asset_tbl$word[asset_tbl$word=="mergers"]<-c("merger")
asset_tbl$word[asset_tbl$word=="merge"]<-c("merger")
asset_tbl$word[asset_tbl$word=="merging"]<-c("merger")
asset_tbl$word[asset_tbl$word=="merges"]<-c("merger")
asset_tbl$word[asset_tbl$word=="merged"]<-c("merger")
asset_tbl<-asset_tbl %>%
  group_by(state_code, statute) %>% 
  mutate(text = paste0(word, collapse = " ")) %>%
  slice(1) %>%
  select(state_code,text,statute)

#Rename table to use in analysis.
statute_tbl<-statute_tbl


#Compute cosine similarity.
seed_words<-c("bond","merger","endowment","asset","dissolution","foreign")
state_cosfin<-list()
lm_sentiments<-unique(lm_lexicon$sentiment)

for (i in state_codes){
  text<-statute_tbl$text[statute_tbl$state_code == i]
  model<-word2vec(text, type="skip-gram", window=10, dim=50, iter=20, stopwords = new_stopwords$word, split = c(" ", ".\n?!"))
  
  
  #Compute financial terms vectors.
  emb_fin<- predict(model, seed_words, type = "embedding")
  v_fin<-emb_fin[complete.cases(emb_fin),]
  
  if (ncol(as_tibble(v_fin))>1) {
    v_fin_mean<-colMeans(v_fin)
    v_fin<-rbind(v_fin,v_fin_mean)
  } else {
    v_fin<-t(tibble(v_fin))
  }
  
  #Compute LM lexicon vectors.
  v_sentiment<-matrix(NA,7,50)
  rownames(v_sentiment)<-unique(lm_lexicon$sentiment)
  for (j in lm_sentiments){
    emb<-predict(model,lm_lexicon$word[lm_lexicon$sentiment==j],type="embedding")
    emb<-emb[complete.cases(emb),]
    
    
    if (length(emb)==0) {
      v_sentiment[which(lm_sentiments==j),]<-colSums(emb)/nrow(emb)
    } else {
      if (ncol(as_tibble(emb))>1){
        v_sentiment[which(lm_sentiments==j),]<-colSums(emb)/nrow(emb)
      } else {
        v_sentiment[which(lm_sentiments==j),]<-emb
        
      }
    }
    
    
  } #end sentiment loop.
  v_sentiment_mean<-colMeans(v_sentiment[rowSums(is.na(v_sentiment)) < ncol(v_sentiment),])
  v_temp<-v_sentiment[rowSums(is.na(v_sentiment)) < ncol(v_sentiment),]
  
  
  #Compute cosine similarity.
  cosim_fin_sentiment<-as.matrix(v_fin)%*%t(as.matrix(v_temp))/(as.matrix(sqrt(rowSums(v_fin^2)))%*%(t(as.matrix(sqrt(rowSums(v_temp^2))))))
  
  state_cosfin[[which(state_codes == i)]]<-cosim_fin_sentiment
} #end state loop.


#========================================================#
#Train on all states, update, and use N closest words.
state_cosfin_refined<-list()
top_25_words<-list()
top_25_words_statute<-list()
vec_dim<-50
lm_neg<-c("negative","constraining")
text<-statute_tbl$text
model<-word2vec(text, type="skip-gram", window=10, dim=vec_dim, iter=20, stopwords = new_stopwords$word, split = c(" ", ".\n?!"))

#Compute financial terms vectors.
top_n_fin<- predict(model, seed_words, type = "nearest", top_n = 100) # use this to find the top 100 most common words related to each seed word to refine the LM Lexicon.
emb_fin<- predict(model, seed_words, type = "embedding")

#Create word vector from top 100 words associated with each seed word within each state.
for (i in state_codes) {
  print(i)
  text<-statute_tbl$text[statute_tbl$state_code == i]
  model<-word2vec(text, type="skip-gram", window=10, dim=vec_dim, iter=20,stopwords = new_stopwords$word, split = c(" ", ".\n?!"))
  v_mean<-matrix(NA,length(seed_words)+1,vec_dim)
  
  #Get top 25 words by state.
  emb_temp<- predict(model, seed_words, type = "embedding")
  temp_seed<-seed_words[!is.na(emb_temp[,1])]
  top_25_words[[i]]<- predict(model, temp_seed, type = "nearest", top_n = 25) 
  
  for (s in statute_tbl$statute) {
    print(s)
    text2<-statute_tbl$text[statute_tbl$statute == s]
    model2<-word2vec(text2, type="skip-gram", window=10, dim=vec_dim, iter=20,stopwords = new_stopwords$word, split = c(" ", ".\n?!"))
    v_mean_statute<-matrix(NA,length(seed_words)+1,vec_dim)

    #Get top 25 words by state.
    emb_temp_statute<- predict(model2, seed_words, type = "embedding")
    temp_seed_statute<-seed_words[!is.na(emb_temp_statute[,1])]
    top_25_words_statute[[i]]<- predict(model2, temp_seed_statute, type = "nearest", top_n = 25) 

 # statute loop
 # train on one statute/state
 # predict top words for each seedword for each statute (feed top_25_words for each state trained on universe)
 # Aggregate
    for (j in seed_words){
        top_n_words_statute<-as_tibble_col(top_n_fin[[j]][["term2"]],column_name="word")
        emb_seed_statute<-predict(model2,top_25_words_statute[[j]][["term2"]],type="embedding")
        v_fin_seed_statute<-emb_seed_statute[complete.cases(emb_seed_statute),]

        if (length(v_fin_seed_statute)==0) {
        v_mean_statute[which(seed_words==j),]<-colSums(v_fin_seed_statute)/nrow(v_fin_seed_statute)
        } else {
        if (ncol(as_tibble(v_fin_seed_statute))>1){
            v_mean_statute[which(seed_words==j),]<-colSums(v_fin_seed_statute)/nrow(v_fin_seed_statute)
        } else {
            v_mean_statute[which(seed_words==j),]<-v_fin_seed_statute
            
        }
        }
      }
    }
  } #end seed word loop.
  
  #Compute merge+foreign.
  v_mean_statute[7,]=v_mean_statute[2,]+v_mean_statute[6,]
  
  #Add row names to v_mean.
  rownames(v_mean_statute)<-c(seed_words,"merge_foreign")
  
  #Create a restricted lexicon for each seed word.
  #temp_lexicon<-inner_join(lm_lexicon,top_n_words)
  #for (k in lm_neg){
  #emb<-predict(model,temp_lexicon$word[temp_lexicon$sentiment==k],type="embedding")
  #emb<-emb[complete.cases(emb),]
  
  #}
  
  #Compute LM lexicon vectors.
  v_sentiment_statute<-matrix(NA,7,vec_dim)
  rownames(v_sentiment_statute)<-unique(lm_lexicon$sentiment)
  for (k in lm_sentiments){
    emb<-predict(model2,lm_lexicon$word[lm_lexicon$sentiment==k],type="embedding")
    emb<-emb[complete.cases(emb),]
    
    
    if (length(emb)==0) {
      v_sentiment_statute[which(lm_sentiments==k),]<-colSums(emb)/nrow(emb)
    } else {
      if (ncol(as_tibble(emb))>1){
        v_sentiment_statute[which(lm_sentiments==k),]<-colSums(emb)/nrow(emb)
      } else {
        v_sentiment_statute[which(lm_sentiments==k),]<-emb
        
      }
    }
  } #end sentiment loop.
  
  #Update sentiment matrix.
  
  v_sentiment_mean_statute<-colMeans(v_sentiment_statute[rowSums(is.na(v_sentiment_statute)) < ncol(v_sentiment_statute),])
  #v_temp<-v_sentiment[rowSums(is.na(v_sentiment)) < ncol(v_sentiment),]
  v_temp_statute<-v_sentiment_statute
  
  
  #Compute cosine similarity.
  cosim_fin_sentiment_statute<-as.matrix(v_mean_statute)%*%t(as.matrix(v_temp_statute))/(as.matrix(sqrt(rowSums(v_mean_statute^2)))%*%(t(as.matrix(sqrt(rowSums(v_temp_statute^2))))))
  state_cosfin_refined[[which(state_codes == i)]]<-cosim_fin_sentiment_statute
  
  
} #end state loop.


#Create state-level dataset of cosine similarities.
temp_words<-rownames(state_cosfin_refined[[1]])
index_vars<-numeric()
for (i in 1:7) {
  index_vars[(i-1)*7+1:7]<-paste0(temp_words,"_",lm_sentiments[i])
}
cossim_tbl<-as_tibble(matrix(nrow = 51, ncol = length(c("state_codes",index_vars))), .name_repair = ~ c("state_codes",index_vars))

for (i in 1:51) {
  cossim_tbl[i,1]<-state_codes[i]
  cossim_tbl[i,2:50]<-matrix(state_cosfin_refined[[i]][1:49],nrow=1, ncol=49)
  cossim_tbl[i,2:50]<-mutate_all(cossim_tbl[i,2:50],~ifelse(is.nan(.), 2, .))
  cossim_tbl[i,2:50]<-mutate_all(cossim_tbl[i,2:50],~ifelse(is.na(.), 2, .))
  cossim_tbl[i,2:50]<-mutate_all(cossim_tbl[i,2:50], function(x) as.numeric(as.character(x)))
}
sapply(cossim_tbl[,2:50], class)
write.csv(cossim_tbl,"cossim_tbl.csv",row.names = FALSE) #make sure directory is correct.

#Save workspace.
save.image("sentiment_workspace.RData") #make sure directory is correct.

#========================================================#
#Crude word association method.
#Load sentiment analysis workspace.
load("sentiment_workspace.RData") #make sure directory is correct.

#Create word count table.
word_count_tbl<-temp_tbl %>%
  group_by(state_code,statute,sentence_no) %>%
  mutate(sentence_neg_n=ifelse(sentiment=="negative",1,0), 
         sentence_merge_n=ifelse(word=="merger",1,0)) %>%
  mutate(sentence_neg_n=sum(sentence_neg_n), 
         sentence_merge_n=sum(sentence_merge_n),
         sentence_neg=ifelse(sentence_neg_n>0,1,0),
         sentence_merge=ifelse(sentence_merge_n>0,1,0),
         sentence_size=n()) %>%
  mutate(sentence_neg_merge=sentence_neg_n*sentence_merge_n/(n()^2),
         sentence_coeff=(sentence_merge_n^(1+(sentence_neg_n/sentence_size)))/sentence_size) %>%
  group_by(state_code,statute) %>%
  mutate(statute_neg_n=ifelse(sentiment=="negative",1,0), 
         statute_merge_n=ifelse(word=="merger",1,0)) %>%
  mutate(statute_neg_n=sum(statute_neg_n), 
         statute_merge_n=sum(statute_merge_n),
         statute_neg=ifelse(statute_neg_n>0,1,0),
         statute_merge=ifelse(statute_merge_n>0,1,0),
         statute_size=n_distinct(sentence_no),
         statute_neg_merge=sum(sentence_neg_merge/sentence_size)/statute_size,
         statute_coeff_mean=sum(sentence_coeff/sentence_size)/statute_size) %>%
  group_by(state_code) %>%
  mutate(state_neg_n=ifelse(sentiment=="negative",1,0), 
         state_merge_n=ifelse(word=="merger",1,0)) %>%
  mutate(state_neg_n=sum(state_neg_n), 
         state_merge_n=sum(state_merge_n),
         state_neg=ifelse(state_neg_n>0,1,0),
         state_merge=ifelse(state_merge_n>0,1,0),
         title_size=n_distinct(statute),
         state_neg_merge=sum(sentence_neg_merge/sentence_size)/title_size,
         state_coeff_mean=sum(sentence_coeff/sentence_size)/title_size)



