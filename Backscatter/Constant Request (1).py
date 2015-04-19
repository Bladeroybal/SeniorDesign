
# coding: utf-8

# In[23]:

##import the modules used in the code
import requests
import time
from bs4 import BeautifulSoup
import urllib
##set up variables used to define the delay and repetition of the clock
## delay is 10 seconds and the repetitions of the loop is set to 10 
sleep_length = 10
repeat = 10

##once the list has shown an update, update the URL to download the file
##given the inputted URL, the contents will be downloaded and a new file 
##will be created locally to store the file



#define a function to download the recently updated file
def download_file(url):
     ## create a local file with the name being the string following the last / of the URL
    local_filename = url.split('/')[-1]   
    # NOTE the stream=True parameter
    r = requests.get(url, stream=True)
    with open(local_filename, 'wb') as f:   ##open the URL file at this location
        for chunk in r.iter_content(chunk_size=1024):   ##
            if chunk: # filter out keep-alive new chunks
                f.write(chunk)    ##write the contents to the local file
                f.flush()         ##clear the downloaded contents
    return local_filename         ##return where to find the file locally


open('Links.txt', 'w').close()  ##clear the Links file

##define a function to obtain a list of the URLs on the server
def getUrls1():
    r = requests.get('http://72.47.166.105:8080/data')  ##send a request for a connection to the server URL
    data = r.text                ##retrieve the text on the page
    soup = BeautifulSoup(data)  ##
    for link in soup.find_all('a'):  ##for all of the text on the page source, search for the URLs format which begins with <a>
        print(link.get('href'))     ##print each links reference
        with open("Links.txt", "a") as f:
         f.write(link.get('href')+'\n')
        
        ##text_file = open("Links.txt", "w")
        ##text_file.write(link.get('href'))

        
##define a function to obtain a list of the URLs on the server
def getUrls():
    r = requests.get('http://72.47.166.105:8080/data')  ##send a request for a connection to the server URL
    data = r.text                ##retrieve the text on the page
    soup = BeautifulSoup(data)  ##
    for link in soup.find_all('a'):  ##for all of the text on the page source, search for the URLs format which begins with <a>
        print(link.get('href'))     ##print each links reference
        if link.get('href') == open('Links.txt').read():
                break
                print ('New File Uploaded')
                file_dwnload = urllib.parse.urlunparse('http://72.47.166.105:8080/data', link.get('href'))
                download_file(file_dwnload)


# In[25]:

##set up a loop to repeat 10 times
##was long as i>0, which is everytime, the loop will delay 10 seconds and then obtain the list of URLs from the site at the time
getUrls1()
for i in range(repeat - 1):
    if i>0:
        time.sleep(sleep_length) ##delay 10 seconds
        getUrls()               ##obtain the URL list at this time


# In[24]:

getUrls1()


# In[ ]:



