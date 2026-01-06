import requests

def scrape(website): # Function to scrape a website
    return requests.get(website) 

website = "https://vilnius.lt/" # scraping vilnius.lt

x = scrape(website)
print(x.text)

