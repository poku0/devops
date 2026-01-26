import sqlite3
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException

# database setup
conn = sqlite3.connect("quotes.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS quotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    quote TEXT NOT NULL,
    author TEXT NOT NULL,
    page INTEGER,
    source_url TEXT
)
""")

conn.commit()

# selenium setup
browser_driver = Service('/opt/homebrew/bin/chromedriver')
driver = webdriver.Chrome(service=browser_driver)
wait = WebDriverWait(driver, 10)

driver.get("https://quotes.toscrape.com/login")

# login
wait.until(EC.presence_of_element_located((By.ID, "username")))

driver.find_element(By.ID, "username").send_keys("admin")
driver.find_element(By.ID, "password").send_keys("admin")
driver.find_element(By.CSS_SELECTOR, "input.btn-primary").click()

# scrape multiple pages
page_number = 1

while True:
    wait.until(EC.presence_of_element_located((By.CLASS_NAME, "quote")))

    quotes = driver.find_elements(By.CLASS_NAME, "quote")

    for q in quotes:
        text = q.find_element(By.CLASS_NAME, "text").text
        author = q.find_element(By.CLASS_NAME, "author").text

        cursor.execute(
            "INSERT INTO quotes (quote, author, page, source_url) VALUES (?, ?, ?, ?)",
            (text, author, page_number, driver.current_url)
        )

    conn.commit()
    print(f"Page {page_number} scraped")

    # Try to go to next page
    try:
        driver.find_element(By.PARTIAL_LINK_TEXT, "Next").click()
        page_number += 1
    except NoSuchElementException:
        print("No more pages.")
        break

# cleanup
driver.quit()
conn.close()
