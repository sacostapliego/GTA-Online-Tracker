import requests
import json
import re

# Configuration
SUBREDDIT = "gtaonline"
SEARCH_URL = f"https://www.reddit.com/r/{SUBREDDIT}/search.json?q=title:%22Weekly+Bonuses+and+Discounts%22&restrict_sr=1&sort=new&limit=1"
OUTPUT_FILE = "data/weekly-update.json"

def fetch_reddit_post():
    headers = {'User-Agent': 'GTAWeeklyTrack/1.0'}
    
    print(f"Fetching from: {SEARCH_URL}")
    response = requests.get(SEARCH_URL, headers=headers)
    
    if response.status_code != 200:
        raise Exception(f"Failed to fetch data: {response.status_code}")
    
    data = response.json()
    posts = data.get('data', {}).get('children', [])
    
    if not posts:
        print("No posts found.")
        return None

    return posts[0]['data']

def clean_text(text):
    """Remove markdown formatting, links, and invisible characters"""
    # Remove markdown links [text](url) -> text
    text = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', text)
    # Remove bold/italic markers
    text = text.replace('**', '').replace('*', '')
    # Remove invisible characters (non-breaking spaces, etc)
    text = text.replace('\u00a0', ' ').replace('\xa0', ' ')
    # Clean up extra whitespace
    text = ' '.join(text.split())
    return text.strip()

def extract_intro_message(body):
    """Extract the introductory messages before the first section header"""
    lines = body.split('\n')
    intro_lines = []
    
    for line in lines:
        stripped = line.strip()
        
        # Stop when we hit the first section (starting with #)
        if stripped.startswith('#'):
            break
        
        # Capture lines that start with *** (bold italic) or have content
        if stripped.startswith('***') and stripped.endswith('***'):
            # Remove the *** markers and clean the text
            message = clean_text(stripped)
            if message:
                intro_lines.append(message)
    
    return intro_lines

def parse_markdown_content(post_data):
    title = post_data.get('title', 'Unknown Date')
    body = post_data.get('selftext', '')

    # Initialize structure
    structured_data = {
        "weekOf": clean_title(title),
        "introMessages": extract_intro_message(body),
        "podiumVehicle": get_vehicle_value(body, "Podium Vehicle"),
        "prizeRideVehicle": get_vehicle_value(body, "Prize Ride Vehicle"),
        "prizeRideChallenge": get_vehicle_value(body, "Prize Ride Challenge"),
        "timeTrial": get_vehicle_value(body, "Time Trial"),
        "premiumRace": get_vehicle_value(body, "Premium Race"),
        "hswTimeTrial": get_vehicle_value(body, "HSW Time Trial"),
        "salvageYardRobberies": extract_salvage_yard_robberies(body),
        "weeklyChallenge": extract_weekly_challenge(body),
        "bonuses": extract_bonuses(body),
        "discounts": extract_discounts(body),
    }

    return structured_data

def clean_title(title):
    return title.split(" - ")[-1] if " - " in title else title

def get_vehicle_value(text, key_phrase):
    """Extract vehicle/challenge info after a colon, removing wiki links"""
    lines = text.split('\n')
    for line in lines:
        if key_phrase in line and ':' in line:
            # First remove markdown links completely
            line = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', line)
            
            # Split by the last colon to get the value
            parts = line.split(':**')
            if len(parts) < 2:
                parts = line.split(':')
            
            if len(parts) > 1:
                value = parts[-1].strip()
                # Remove bold markers
                value = value.replace('**', '').replace('*', '')
                # Remove any remaining parenthetical content
                value = re.sub(r'\([^)]*\)', '', value).strip()
                # Remove any remaining URL fragments
                value = re.sub(r'https?://[^\s]+', '', value).strip()
                value = re.sub(r'//[^\s:)]+\)', '', value).strip()
                # Clean up extra whitespace
                value = ' '.join(value.split())
                return value
    return "Not found"

def extract_salvage_yard_robberies(body):
    """Extract the three salvage yard robbery types and vehicles"""
    robberies = []
    lines = body.split('\n')
    capturing = False
    
    for line in lines:
        stripped = line.strip()
        
        # Start capturing after "This Week's Salvage Yard Robberies" header
        if "Salvage Yard Robberies" in stripped:
            capturing = True
            continue
        
        # Stop at next section
        if capturing and stripped.startswith('**') and 'Robbery' not in stripped:
            break
        
        # Capture robbery vehicles - extract both type and vehicle
        if capturing and stripped.startswith('*') and 'Robbery:' in stripped:
            # Remove bullet point and split by colon
            robbery_text = clean_text(stripped[1:])
            if ':' in robbery_text:
                robbery_type, vehicle = robbery_text.split(':', 1)
                robberies.append({
                    "type": robbery_type.strip(),
                    "vehicle": vehicle.strip()
                })
    
    return robberies

def extract_weekly_challenge(body):
    """Extract this week's challenge"""
    lines = body.split('\n')
    capturing = False
    
    for line in lines:
        stripped = line.strip()
        
        # Start capturing after "This Week's Challenge" header
        if "This Week's Challenge" in stripped:
            capturing = True
            continue
        
        # Stop at next section
        if capturing and stripped.startswith('**'):
            break
        
        # Capture the challenge
        if capturing and stripped.startswith('*'):
            return clean_text(stripped[1:])
    
    return "Not found"

def extract_bonuses(body):
    """Extract the actual money/RP bonuses with their multipliers (2X, 3X, 4X, etc.)"""
    lines = body.split('\n')
    bonuses = []
    capturing = False
    current_multiplier = None
    
    for line in lines:
        stripped = line.strip()
        
        # Start capturing after "# Bonuses" header
        if stripped.startswith('# Bonuses'):
            capturing = True
            continue
        
        # Stop at next major section
        if capturing and stripped.startswith('# '):
            break
        
        # Capture multiplier headers (e.g., "4X GTA$ and RP", "2X GTA$", "3X RP")
        if capturing and stripped.startswith('**') and stripped.endswith('**'):
            # Check if it contains multiplier pattern (e.g., "2X", "3X", "4X")
            multiplier_match = re.search(r'(\d+X\s+[^*]+)', stripped)
            if multiplier_match:
                current_multiplier = clean_text(stripped)
            continue
        
        # Capture bonus items and prepend the multiplier
        if capturing and stripped.startswith('*') and current_multiplier:
            item = clean_text(stripped[1:])  # Remove the bullet point
            if item:
                bonuses.append(f"{current_multiplier} - {item}")
    
    return bonuses if bonuses else ["See full post for details"]

def extract_discounts(body):
    """Extract discount items"""
    lines = body.split('\n')
    discounts = []
    capturing = False
    current_discount = None
    
    for line in lines:
        stripped = line.strip()
        
        # Start capturing after "# Discounts" header
        if stripped.startswith('# Discounts'):
            capturing = True
            continue
        
        # Stop at next major section
        if capturing and stripped.startswith('# '):
            break
        
        # Capture discount percentage headers
        if capturing and ('Off' in stripped or 'Free' in stripped) and stripped.startswith('**'):
            current_discount = clean_text(stripped)
            continue
        
        # Capture items under each discount category
        if capturing and stripped.startswith('*') and current_discount:
            item = clean_text(stripped[1:])
            if item:
                discounts.append(f"{current_discount}: {item}")
    
    return discounts if discounts else ["See full post for details"]

def main():
    try:
        post = fetch_reddit_post()
        if post:
            parsed_data = parse_markdown_content(post)
            
            with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
                json.dump(parsed_data, f, indent=2, ensure_ascii=False)
            
            print(f"Data saved to {OUTPUT_FILE}")
            
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    main()