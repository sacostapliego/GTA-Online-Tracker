"""
Main entry point for the GTA Online Weekly Tracker scraper.
Fetches the weekly Reddit post and saves structured data to JSON.
"""
import json
import requests

from weekly_scraper import fetch_reddit_post, parse_markdown_content

# Configuration
SUBREDDIT = "gtaonline"
SEARCH_URL = f"https://api.pullpush.io/reddit/search/submission/?subreddit={SUBREDDIT}&title=%22Weekly%20Bonuses%20and%20Discounts%22&size=1"
OUTPUT_FILE = "data/weekly-update.json"


def main():
    try:
        post = fetch_reddit_post(SEARCH_URL)
        if post:
            parsed_data = parse_markdown_content(post)

            with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
                json.dump(parsed_data, f, indent=2, ensure_ascii=False)

            print(f"Data saved to {OUTPUT_FILE}")

    except Exception as e:
        print(f"Error: {str(e)}")


if __name__ == "__main__":
    main()
