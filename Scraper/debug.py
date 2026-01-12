import requests

SUBREDDIT = "gtaonline"
SEARCH_URL = f"https://www.reddit.com/r/{SUBREDDIT}/search.json?q=title:%22Weekly+Bonuses+and+Discounts%22&restrict_sr=1&sort=new&limit=1"

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
            
            # Save raw body
            with open('debug_body.txt', 'w', encoding='utf-8') as f:
                f.write(body)
            
            print(f"\n=== DEBUG INFO ===")
            print(f"Title: {title}")
            print(f"Body length: {len(body)} characters")
            print(f"Author: {post.get('author', 'Unknown')}")
            print(f"Score: {post.get('score', 0)}")
            print(f"Permalink: https://reddit.com{post.get('permalink', '')}")
            print(f"\nFull body saved to: debug_body.txt")
            
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()