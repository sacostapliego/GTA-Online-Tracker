from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from special_cases import SPECIAL_CASES
import json
import re
import time

# Base URL for the vehicle pages
BASE_URL = "https://gtacars.net/gta5/"
OUTPUT_FILE = "data/vehicle_data.json"

# Special cases where the vehicle name doesn't match the URL format
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

def extract_price(driver):
    """
    Extract the vehicle price from the page.
    Targets the first <data> element with price class.
    """
    try:
        # Look for the data element with price
        price_element = driver.find_element(By.CSS_SELECTOR, "data.text-lg.text-green-500, data.text-lg.text-green-600")
        price_value = price_element.get_attribute('value')
        
        if price_value:
            return int(price_value)
        else:
            # Fallback: parse the text content
            price_text = price_element.text
            price_clean = re.sub(r'[^\d]', '', price_text)
            return int(price_clean) if price_clean else None
    except Exception as e:
        print(f"  Could not extract price: {e}")
        return None

def calculate_discounted_price(original_price, discount_percent):
    """
    Calculate the discounted price based on the percentage off.
    """
    if original_price and discount_percent:
        discount_amount = original_price * (discount_percent / 100)
        return int(original_price - discount_amount)
    return None

def scrape_vehicle_data(driver, vehicle_url_name, discount_percent=None):
    """
    Scrape the vehicle image URL and price from gtacars.net using Selenium
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
        
        if image_src and image_src.startswith('/'):
            image_src = f"https://gtacars.net{image_src}"
        
        # Extract price
        original_price = extract_price(driver)
        discounted_price = calculate_discounted_price(original_price, discount_percent) if discount_percent else None
        
        return {
            "image_url": image_src,
            "original_price": original_price,
            "discounted_price": discounted_price,
            "discount_percent": discount_percent
        }
            
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return None

def process_weekly_update(json_file_path):
    """
    Process the weekly-update.json file and fetch data for discounted vehicles,
    podium vehicle, prize ride vehicle, and salvage yard robbery vehicles
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
    
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=chrome_options)
    
    results = {}
    failed_vehicles = []  # Track failed vehicles
    
    try:
        # Process podium vehicle
        if 'podiumVehicle' in data:
            vehicle_name = data['podiumVehicle']
            url_name = normalize_vehicle_name(vehicle_name)
            
            print(f"Fetching data for Podium Vehicle: {vehicle_name} ({url_name})...")
            vehicle_data = scrape_vehicle_data(driver, url_name)
            
            if vehicle_data:
                results[vehicle_name] = {
                    "type": "Podium Vehicle",
                    "url": f"{BASE_URL}{url_name}",
                    **vehicle_data
                }
            else:
                failed_vehicles.append((vehicle_name, url_name, "Podium Vehicle"))
            time.sleep(0.5)
        
        # Process prize ride vehicle
        if 'prizeRideVehicle' in data:
            vehicle_name = data['prizeRideVehicle']
            url_name = normalize_vehicle_name(vehicle_name)
            
            print(f"Fetching data for Prize Ride Vehicle: {vehicle_name} ({url_name})...")
            vehicle_data = scrape_vehicle_data(driver, url_name)
            
            if vehicle_data:
                results[vehicle_name] = {
                    "type": "Prize Ride Vehicle",
                    "url": f"{BASE_URL}{url_name}",
                    **vehicle_data
                }
            else:
                failed_vehicles.append((vehicle_name, url_name, "Prize Ride Vehicle"))
            time.sleep(0.5)
        
        # Process salvage yard robbery vehicles
        if 'salvageYardRobberies' in data:
            for robbery in data['salvageYardRobberies']:
                vehicle_name = robbery['vehicle']
                robbery_type = robbery['type']
                url_name = normalize_vehicle_name(vehicle_name)
                
                print(f"Fetching data for {robbery_type}: {vehicle_name} ({url_name})...")
                vehicle_data = scrape_vehicle_data(driver, url_name)
                
                if vehicle_data:
                    results[vehicle_name] = {
                        "type": robbery_type,
                        "url": f"{BASE_URL}{url_name}",
                        **vehicle_data
                    }
                else:
                    failed_vehicles.append((vehicle_name, url_name, robbery_type))
                time.sleep(0.5)
        
        # Process discounts
        if 'discounts' in data:
            for discount in data['discounts']:
                # Extract discount percentage
                discount_match = re.match(r'(\d+)%\s+Off:\s+(.+)', discount)
                if not discount_match:
                    continue
                
                discount_percent = int(discount_match.group(1))
                vehicle_name = discount_match.group(2)
                
                # Skip non-vehicle items
                if "Properties" in vehicle_name or "Upgrades" in vehicle_name or "Modifications" in vehicle_name or "Offices" in vehicle_name:
                    print(f"Skipping non-vehicle: {vehicle_name}")
                    continue
                
                # Get URL-friendly name
                url_name = normalize_vehicle_name(vehicle_name)
                
                # Scrape data
                print(f"Fetching data for Discount: {vehicle_name} ({url_name})...")
                vehicle_data = scrape_vehicle_data(driver, url_name, discount_percent)
                
                if vehicle_data:
                    results[vehicle_name] = {
                        "type": "Discount",
                        "discount": discount,
                        "url": f"{BASE_URL}{url_name}",
                        **vehicle_data
                    }
                else:
                    failed_vehicles.append((vehicle_name, url_name, "Discount"))
                
                # avoid overwhelming the server
                time.sleep(0.5)
    finally:
        driver.quit()
    
    return results, failed_vehicles

# Example usage
if __name__ == "__main__":
    json_path = "data/weekly-update.json"   
     
    print("Starting vehicle data scraper with Selenium...\n")
    vehicle_data, failed_vehicles = process_weekly_update(json_path)
    
    # Print results
    print("\n--- Results ---")
    for vehicle, info in vehicle_data.items():
        print(f"\n{vehicle} ({info.get('type', 'Unknown')}):")
        print(f"  URL: {info['url']}")
        print(f"  Image: {info['image_url']}")
        print(f"  Original Price: ${info['original_price']:,}" if info['original_price'] else "  Original Price: Not found")
        if info.get('discounted_price'):
            print(f"  Discounted Price: ${info['discounted_price']:,}")
            print(f"  Discount: {info['discount_percent']}%")
            
    # Print failed vehicles
    if failed_vehicles:
        print("\n\n--- FAILED VEHICLES (Add to special_cases.py) ---")
        print("The following vehicles failed to scrape. Add them to SPECIAL_CASES:\n")
        for vehicle_name, attempted_url, vehicle_type in failed_vehicles:
            print(f'    "{vehicle_name}": "correct-url-here",  # {vehicle_type} - Attempted: {attempted_url}')
    
    # Save to JSON file
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(vehicle_data, f, indent=2)
    
    print(f"\n\nResults saved to: {OUTPUT_FILE}")