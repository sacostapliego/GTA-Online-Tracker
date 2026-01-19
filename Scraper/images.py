from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
import json
import re
import time

# Base URL for the vehicle pages
BASE_URL = "https://gtacars.net/gta5/"
OUTPUT_FILE = "vehicle_images.json"

# Special cases where the vehicle name doesn't match the URL format
SPECIAL_CASES = {
    "Rhino Tank": "rhino",
    "Dashound": "coach",
    "Declasse Vigero ZX": "vigero2",
    "Obey Omnis e-GT": "omnisegt",
    "Albany Cavalcade XL": "cavalcade3",
    "Vapid Dominator FX": "dominator10"
}

def normalize_vehicle_name(vehicle_name):
    """
    Convert vehicle name to URL-friendly format.
    Example: "Cheval Taipan" -> "taipan"
    """
    # Check for special cases first
    if vehicle_name in SPECIAL_CASES:
        return SPECIAL_CASES[vehicle_name]
    
    # Remove percentage and "Off:" text if present
    vehicle_name = re.sub(r'\d+%\s+Off:\s+', '', vehicle_name)
    
    # Split by space and take the last word (model name)
    parts = vehicle_name.strip().split()
    if len(parts) >= 2:
        return parts[-1].lower()
    return vehicle_name.lower()

def scrape_vehicle_image(driver, vehicle_url_name):
    """
    Scrape the vehicle image URL from gtacars.net using Selenium
    """
    url = f"{BASE_URL}{vehicle_url_name}"
    
    try:
        driver.get(url)
        
        # Wait for the image to load (max 10 seconds)
        wait = WebDriverWait(driver, 10)
        img_element = wait.until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "img.rounded-t-lg"))
        )
        
        image_src = img_element.get_attribute('src')
        
        if image_src:
            # Construct full URL if relative path
            if image_src.startswith('/'):
                image_src = f"https://gtacars.net{image_src}"
            return image_src
        else:
            print(f"No image src found for {vehicle_url_name}")
            return None
            
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return None

def process_weekly_update(json_file_path):
    """
    Process the weekly-update.json file and fetch images for discounted vehicles
    """
    with open(json_file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Setup Selenium with headless Chrome
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    
    driver = webdriver.Chrome(options=chrome_options)
    
    results = {}
    
    try:
        # Process discounts
        if 'discounts' in data:
            for discount in data['discounts']:
                # Extract vehicle name (e.g., "30% Off: Cheval Taipan" -> "Cheval Taipan")
                vehicle_name = re.sub(r'\d+%\s+Off:\s+', '', discount)
                
                # Skip non-vehicle items
                if "Properties" in vehicle_name or "Upgrades" in vehicle_name or "Modifications" in vehicle_name:
                    print(f"Skipping non-vehicle: {vehicle_name}")
                    continue
                
                # Get URL-friendly name
                url_name = normalize_vehicle_name(vehicle_name)
                
                # Scrape image
                print(f"Fetching image for: {vehicle_name} ({url_name})...")
                image_url = scrape_vehicle_image(driver, url_name)
                
                results[vehicle_name] = {
                    "discount": discount,
                    "url": f"{BASE_URL}{url_name}",
                    "image_url": image_url
                }
                
                # avoid overwhelming the server
                time.sleep(0.5)
    finally:
        driver.quit()
    
    return results

# Example usage
if __name__ == "__main__":
    json_path = "weekly-update.json"   
     
    print("Starting vehicle image scraper with Selenium...\n")
    vehicle_data = process_weekly_update(json_path)
    
    # Print results
    print("\n--- Results ---")
    for vehicle, info in vehicle_data.items():
        print(f"\n{vehicle}:")
        print(f"  URL: {info['url']}")
        print(f"  Image: {info['image_url']}")
    
    # Save to JSON file
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(vehicle_data, f, indent=2)
    
    print(f"\n\nResults saved to: {OUTPUT_FILE}")