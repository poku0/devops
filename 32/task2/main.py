import requests
import bs4 as BeautifulSoup

def scrape(website): # Function to scrape a website
    response = requests.get(website)
    soup = BeautifulSoup.BeautifulSoup(response.text, 'html.parser')
    headers = soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])
    formatted_headers = []
    for header in headers:
        level = int(header.name[1])  # Get the header level (1-6)
        indent = '  ' * (level - 1)  # Indent based on level
        formatted_headers.append(f"{indent}• {header.get_text().strip()}")
    return '\n'.join(formatted_headers)

website = "https://vilnius.lt/" # scraping vilnius.lt
x = scrape(website)
print(x)
