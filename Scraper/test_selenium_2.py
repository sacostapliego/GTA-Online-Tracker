from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
options = Options()
options.add_argument('--headless')
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
driver.get('https://www.reddit.com/r/gtaonline/search.json?q=title:%22Weekly+Bonuses+and+Discounts%22&restrict_sr=1&sort=new&limit=1')
print(driver.page_source[:500])
driver.quit()
