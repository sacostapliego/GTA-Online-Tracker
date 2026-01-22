import { StyleSheet, ScrollView, View, Text, Image } from 'react-native';
import { useEffect, useState } from 'react';
import { Fonts } from '@/constants/theme';

interface WeeklyData {
  weekOf: string;
  bonuses: string[];
}

interface GTAImageData {
  [key: string]: {
    imageURL: string;
  };
}

interface PropertyImageData {
  [key: string]: {
    image1: string;
    image2: string;
  };
}

interface BonusItem {
  text: string;
  imageUrl: string;
}

const DEFAULT_IMAGE = 'https://static.wikia.nocookie.net/gtawiki/images/5/50/GTAOnlineWebsite-ScreensPC-589-3840.jpg/revision/latest/scale-to-width-down/1000?cb=20210629175043';

export default function BonusesTab() {
  const [weeklyData, setWeeklyData] = useState<WeeklyData | null>(null);
  const [bonuses, setBonuses] = useState<BonusItem[]>([]);

  useEffect(() => {
    const data = require('@/assets/data/weekly-update.json');
    const gtaImages: GTAImageData = require('@/assets/data/gta_images.json');
    const propertyImages: PropertyImageData = require('@/assets/data/property_images.json');
    
    setWeeklyData(data);
    
    // Counter to track image usage for properties
    const propertyImageCounter: { [key: string]: number } = {};

    // Parse bonuses and match with images
    const parsedBonuses = data.bonuses.map((bonus: string) => {
      let imageUrl = DEFAULT_IMAGE;
      
      // First, check gta_images.json for matches
      const gtaImageMatch = Object.keys(gtaImages).find(key => 
        bonus.toLowerCase().includes(key.toLowerCase())
      );
      
      if (gtaImageMatch) {
        imageUrl = gtaImages[gtaImageMatch].imageURL;
      } else {
        // If no match in gta_images, check property_images.json
        const propertyMatch = Object.keys(propertyImages).find(propertyKey => 
          bonus.toLowerCase().includes(propertyKey.toLowerCase())
        );
        
        if (propertyMatch) {
          // Increment counter for this property
          propertyImageCounter[propertyMatch] = (propertyImageCounter[propertyMatch] || 0) + 1;
          const imageKey = `image${propertyImageCounter[propertyMatch]}` as 'image1' | 'image2';
          imageUrl = propertyImages[propertyMatch]?.[imageKey] || propertyImages[propertyMatch]?.image1 || DEFAULT_IMAGE;
        }
      }
      
      return {
        text: bonus,
        imageUrl,
      };
    });
    
    setBonuses(parsedBonuses);
  }, []);

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Weekly Bonuses</Text>
        {weeklyData && (
          <Text style={styles.weekText}>{weeklyData.weekOf}</Text>
        )}
      </View>

      <View style={styles.bonusesList}>
        {bonuses.map((bonus, index) => (
          <View key={index} style={styles.bonusItem}>
            <Image 
              source={{ uri: bonus.imageUrl }}
              style={styles.bonusImage}
              defaultSource={require('@/assets/images/temp.png')}
              onError={() => console.log('Failed to load image for:', bonus.text)}
            />
            
            <View style={styles.bonusInfo}>
              <Text style={styles.bonusText}>{bonus.text}</Text>
            </View>
          </View>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
  },
  header: {
    padding: 20,
    paddingTop: 60,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#ffffff',
    fontFamily: Fonts.rounded,
    marginBottom: 8,
  },
  weekText: {
    fontSize: 14,
    color: '#888888',
  },
  bonusesList: {
    padding: 10,
  },
  bonusItem: {
    flexDirection: 'row',
    padding: 12,
    marginBottom: 12,
    alignItems: 'center',
  },
  bonusImage: {
    width: "50%",
    height: 100,
    borderRadius: 6,
    resizeMode: 'cover',
  },
  bonusInfo: {
    flex: 1,
    marginLeft: 16,
  },
  bonusText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#ffffff',
  },
});