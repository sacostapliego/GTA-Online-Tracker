import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Image } from 'react-native';
import { Fonts } from '@/constants/theme';

interface WeeklyData {
  weekOf: string;
  discounts: string[];
}

interface VehicleImageData {
  [key: string]: {
    discount: string;
    url: string;
    image_url: string;
    original_price: number;
    discounted_price: number;
  };
}

interface DiscountItem {
  percentage: string;
  name: string;
  imageUrl: string | null;
  originalPrice: number | null;
  discountedPrice: number | null;
} 

interface PropertyImageData {
  [key: string]: {
    image1: string;
    image2: string;
  };
}

export default function DiscountsTab() {
  const [weeklyData, setWeeklyData] = useState<WeeklyData | null>(null);
  const [discounts, setDiscounts] = useState<DiscountItem[]>([]);

  useEffect(() => {
    const propertyImages: PropertyImageData = require('@/assets/data/property_images.json');

    const processData = (data: WeeklyData, vehicleImages: VehicleImageData) => {
      setWeeklyData(data);

      const propertyImageCounter: { [key: string]: number } = {};

      const parsedDiscounts = data.discounts.map((discount: string) => {
        const [percentage, name] = discount.split(': ');

        let imageUrl = null;

        const matchedProperty = Object.keys(propertyImages).find(propertyKey =>
          name.includes(propertyKey)
        );

        if (matchedProperty) {
          propertyImageCounter[matchedProperty] = (propertyImageCounter[matchedProperty] || 0) + 1;
          const imageKey = `image${propertyImageCounter[matchedProperty]}` as 'image1' | 'image2';
          imageUrl = propertyImages[matchedProperty]?.[imageKey] || propertyImages[matchedProperty]?.image1 || null;
        } else {
          const vehicleData = vehicleImages[name];
          imageUrl = vehicleData?.image_url || null;
        }

        return {
          percentage,
          name,
          imageUrl,
          originalPrice: vehicleImages[name]?.original_price || null,
          discountedPrice: vehicleImages[name]?.discounted_price || null,
        };
      });

      setDiscounts(parsedDiscounts);
    };

    Promise.all([
      fetch('https://raw.githubusercontent.com/sacostapliego/GTA-Online-Tracker/refs/heads/main/Scraper/data/weekly-update.json').then(res => res.json()),
      fetch('https://raw.githubusercontent.com/sacostapliego/GTA-Online-Tracker/refs/heads/main/Scraper/data/vehicle_data.json').then(res => res.json()),
    ])
      .then(([data, vehicleImages]) => processData(data, vehicleImages))
      .catch(() => {
        processData(require('@/assets/data/fallback.json'), {});
      });
  }, []);

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Weekly Discounts</Text>
        {weeklyData && (
          <Text style={styles.weekText}>{weeklyData.weekOf}</Text>
        )}
      </View>

      <View style={styles.discountsList}>
        {discounts.map((discount, index) => (
          <View key={index} style={styles.discountItem}>
            {discount.imageUrl ? (
              <Image 
                source={{ uri: discount.imageUrl }}
                style={styles.vehicleImage}
                defaultSource={require('@/assets/images/temp.png')}
                onError={() => console.log('Failed to load image for:', discount.name)}
              />
            ) : (
              <View style={styles.placeholderImage}>
                <Text style={styles.placeholderText}>?</Text>
              </View>
            )}
            
            <View style={styles.discountInfo}>
              <Text style={styles.vehicleName}>{discount.name}</Text>
              <Text style={styles.percentage}>{discount.percentage}</Text>
              {discount.originalPrice !== null && discount.discountedPrice !== null && (
                <>
                  <Text style={styles.originalPrice}>
                    ${discount.originalPrice.toLocaleString()}
                  </Text>
                  <Text style={styles.price}>
                    ${discount.discountedPrice.toLocaleString()}
                  </Text>
                </>
              )}
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
  discountsList: {
    padding: 10,
  },
  discountItem: {
    flexDirection: 'row',
    padding: 12,
    marginBottom: 12,
    alignItems: 'center',
  },
  vehicleImage: {
    width: "50%",
    height: 100,
    borderRadius: 6,
    resizeMode: 'cover',
  },
  placeholderImage: {
    width: "50%",
    height: 75,
    borderRadius: 6,
    backgroundColor: '#2a2a2a',
    justifyContent: 'center',
    alignItems: 'center',
  },
  placeholderText: {
    fontSize: 30,
    color: '#ffffff',
  },
  discountInfo: {
    flex: 1,
    marginLeft: 16,
  },
  vehicleName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#ffffff',
    marginBottom: 4,
  },
  percentage: {
    fontSize: 14,
    color: '#ffffff',
    fontWeight: 'bold',
  },
  originalPrice: {
    fontSize: 12,
    color: '#ff6666',
    textDecorationLine: 'line-through',
    marginTop: 4,
  },
  price: {
    fontSize: 12,
    color: '#cccccc',
    marginTop: 4,
  },
});