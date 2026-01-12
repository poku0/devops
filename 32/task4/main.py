from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time

driver = webdriver.Chrome()  # initialize the driver

driver.get("https://news.ycombinator.com/")  # navigate to the website you want to scrape

search_box = driver.find_element(By.TAG_NAME, "input")  # locate search box 
search_box.send_keys("nordvpn")  # search for something
search_box.send_keys(Keys.RETURN)  # simulate pressing enter

time.sleep(5)  # wait 5 seconds

driver.quit()  # close webdriver

