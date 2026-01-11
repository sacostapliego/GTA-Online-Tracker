# Workflow plan
1. Source - a script scrapes pinned post from r/gtaonline
2. Automation - github actions to run script automatically every Thursday 12am est
3. Storage - script saves the data as a json file and commits to firebase
4. Expo app - make a request to fetch this json file