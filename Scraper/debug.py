import re
from pathlib import Path

import requests

SUBREDDIT = "gtaonline"
SEARCH_URL = f"https://www.reddit.com/r/{SUBREDDIT}/search.json?q=title:%22Weekly+Bonuses+and+Discounts%22&restrict_sr=1&sort=new&limit=1"


def build_filename_from_title(title):
    """Build a file name like March12-March19 from the weekly title."""
    pattern = re.compile(
        r"-\s*(January|February|March|April|May|June|July|August|September|October|November|December)\s+"
        r"(\d{1,2})(?:st|nd|rd|th)?\s+to\s+"
        r"(January|February|March|April|May|June|July|August|September|October|November|December)?\s*"
        r"(\d{1,2})(?:st|nd|rd|th)?",
        re.IGNORECASE,
    )

    match = pattern.search(title or "")
    if not match:
        return None

    start_month, start_day, end_month, end_day = match.groups()
    start_month = start_month.capitalize()
    end_month = (end_month or start_month).capitalize()

    return f"{start_month}{int(start_day)}-{end_month}{int(end_day)}"

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

def main():
    """
    Debug tool to view raw Reddit post data.
    Saves the body to debug_body.txt and prints key information.
    """
    try:
        post = fetch_reddit_post()
        if post:
            title = post.get('title', 'Unknown')
            body = post.get('selftext', '')
            output_dir = Path(__file__).parent / 'debug'
            output_dir.mkdir(parents=True, exist_ok=True)

            filename_stem = build_filename_from_title(title) or 'debug_body'
            output_file = output_dir / f"{filename_stem}.txt"

            # Save raw body in Scraper/debug using a title-based file name when possible.
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(body)
            
            print(f"\n=== DEBUG INFO ===")
            print(f"Title: {title}")
            print(f"Body length: {len(body)} characters")
            print(f"Author: {post.get('author', 'Unknown')}")
            print(f"Score: {post.get('score', 0)}")
            print(f"Permalink: https://reddit.com{post.get('permalink', '')}")
            print(f"\nFull body saved to: {output_file}")
            
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()