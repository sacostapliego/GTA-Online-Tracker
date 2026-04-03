"""
Weekly update scraper - extracts structured data from Reddit GTA Online weekly posts.
Contains all parsing and extraction logic for the markdown content.
"""
import re
import requests


def _is_discount_header(text):
    """Return True for markdown headers like '**35% off**', '**Free**', etc."""
    cleaned = clean_text(text).lower()
    return (
        "% off" in cleaned
        or cleaned == "free"
        or cleaned.startswith("free for gta+")
        or "off for gta+" in cleaned
    )


def fetch_reddit_post(search_url):
    """Fetch the latest weekly bonuses post from Reddit."""
    headers = {'User-Agent': 'GTAWeeklyTrack/1.0'}

    print(f"Fetching from: {search_url}")
    response = requests.get(search_url, headers=headers)

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


def clean_title(title):
    """Extract date from title (e.g., 'Weekly Bonuses - March 5th' -> 'March 5th')"""
    return title.split(" - ")[-1] if " - " in title else title


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
                vehicle = re.sub(r'\s+with\s+.*$', '', vehicle.strip(), flags=re.IGNORECASE)
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

        # Stop when we reach any discount section header
        if capturing and stripped.startswith('#') and 'discount' in clean_text(stripped).lower():
            break

        # Stop if a discount-rate subheader appears (e.g., "**35% off**", "**Free**")
        if capturing and stripped.startswith('**') and stripped.endswith('**') and _is_discount_header(stripped):
            break

        # Ignore subsection headings inside the bonuses block
        if capturing and stripped.startswith('#'):
            continue

        # Capture multiplier headers (e.g., "4X GTA$ and RP", "2X GTA$", "3X RP")
        if capturing and stripped.startswith('**') and stripped.endswith('**'):
            # Check if it contains multiplier pattern (e.g., "2X", "3X", "4X")
            if re.search(r'\b\d+X\b', stripped):
                current_multiplier = clean_text(stripped)
            continue

        # Capture bonus items and prepend the multiplier
        if capturing and stripped.startswith('*') and current_multiplier:
            item = clean_text(stripped[1:])  # Remove the bullet point
            # Occasional source typo in weekly post body.
            if item.lower().startswith('ommunity '):
                item = f"C{item}"
            if item:
                bonuses.append(f"{current_multiplier} - {item}")

    return bonuses if bonuses else ["See full post for details"]


def _extract_discount_section(body, section_header):
    """
    Generic discount extraction. Captures items under percentage headers.
    Used for both regular discounts and Gun Van discounts.
    """
    lines = body.split('\n')
    discounts = []
    capturing = False
    current_discount = None

    for line in lines:
        stripped = line.strip()

        # Start capturing after the section header
        if section_header in stripped and stripped.startswith('#'):
            capturing = True
            continue

        # Stop at next major section
        if capturing and stripped.startswith('# '):
            break

        # Capture discount percentage headers
        if capturing and ('Off' in stripped or 'off' in stripped or 'Free' in stripped) and stripped.startswith('**'):
            current_discount = clean_text(stripped)
            continue

        # Capture items under each discount category
        if capturing and stripped.startswith('*') and current_discount:
            item = clean_text(stripped[1:])
            if item:
                discounts.append(f"{current_discount}: {item}")

    return discounts


def extract_discounts(body):
    """Extract all non-Gun Van discount items (regular + special discount blocks)."""
    lines = body.split('\n')
    discounts = []
    capturing = False
    current_discount = None

    for line in lines:
        stripped = line.strip()

        if stripped.startswith('#'):
            header = clean_text(stripped).lower()

            # Ignore Gun Van discounts; those are handled by extract_gun_van_discounts.
            if 'gun van discounts' in header:
                if capturing:
                    break
                continue

            # Start or continue capture for any other discount section.
            if 'discount' in header:
                capturing = True
                current_discount = None
                continue

            # End capture on first non-discount header after discount sections.
            if capturing:
                break

        if not capturing:
            continue

        if stripped.startswith('**') and stripped.endswith('**') and _is_discount_header(stripped):
            current_discount = clean_text(stripped)
            continue

        if stripped.startswith('*') and current_discount:
            item = clean_text(stripped[1:])
            if item:
                discounts.append(f"{current_discount}: {item}")

    return discounts if discounts else ["See full post for details"]


def extract_gun_van_discounts(body):
    """Extract Gun Van featured discount items (40% off Railgun, etc.)"""
    return _extract_discount_section(body, "# Gun Van Discounts")


def extract_gun_van_stock(body):
    """
    Extract full Gun Van Stock from the Gun Van Location section.
    Captures Weapons and Throwables with (Discount%, GTA+Discount%) format.
    """
    lines = body.split('\n')
    stock = []
    capturing = False

    for line in lines:
        stripped = line.strip()

        # Start capturing after Gun Van Location/Stock section (not Gun Van Discounts)
        if stripped.startswith('#') and ('Gun Van Location' in stripped or 'Gun Van Stock' in stripped):
            capturing = True
            continue

        # Stop at next major section
        if capturing and stripped.startswith('# '):
            break

        # Capture items matching: * Name (X%, Y%)
        if capturing and stripped.startswith('*') and re.search(r'\(\d+%,\s*\d+%\)', stripped):
            item = clean_text(stripped[1:])
            if item:
                stock.append(item)

    return stock


def parse_markdown_content(post_data):
    """Parse Reddit post data into structured JSON format"""
    title = post_data.get('title', 'Unknown Date')
    body = post_data.get('selftext', '')

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
        "gunVanDiscounts": extract_gun_van_discounts(body),
        "gunVanStock": extract_gun_van_stock(body),
    }

    return structured_data
