import { StyleSheet, ScrollView, View, Text, Image, FlatList, Dimensions } from 'react-native';
import { useEffect, useState, useRef } from 'react';
import { Fonts } from '@/constants/theme';

interface WeeklyData {
  weekOf: string;
  introMessages: string[];
  weeklyChallenge: string;
  podiumVehicle: string;
  prizeRideVehicle: string;
  prizeRideChallenge: string;
  timeTrial: string;
  premiumRace: string;
  hswTimeTrial: string;
  salvageYardRobberies: {
    type: string;
    vehicle: string;
  }[];
}

interface VehicleImageData {
  [key: string]: {
    type: string;
    image_url: string;
    original_price: number | null;
  };
}

const DEFAULT_IMAGE = 'https://static.wikia.nocookie.net/gtawiki/images/5/50/GTAOnlineWebsite-ScreensPC-589-3840.jpg/revision/latest/scale-to-width-down/1000?cb=20210629175043';
const { width } = Dimensions.get('window');

export default function HomeScreen() {
  const [weeklyData, setWeeklyData] = useState<WeeklyData | null>(null);
  const [vehicleImages, setVehicleImages] = useState<VehicleImageData>({});

  useEffect(() => {
    const data = require('@/assets/data/weekly-update.json');
    const images = require('@/assets/data/vehicle_images.json');
    setWeeklyData(data);
    setVehicleImages(images);
  }, []);

  const getVehicleImage = (vehicleName: string): string => {
    return vehicleImages[vehicleName]?.image_url || DEFAULT_IMAGE;
  };

  const formatPrice = (price: number | null): string => {
    if (!price) return 'Price unavailable';
    return `$${price.toLocaleString()}`;
  };

  if (!weeklyData) {
    return (
      <View style={styles.container}>
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>GTA Online Tracker</Text>
      </View>

      {/* Intro Messages */}
      <View style={styles.introSection}>
        <View >
          {weeklyData.introMessages.map((message, index) => (
            <Text key={index} style={styles.introText}>{message}</Text>
          ))}
        </View>
      </View>

      {/* Weekly Challenge */}
      <View style={styles.challengeSection}>
        <Text style={styles.sectionTitle}>Weekly Challenge</Text>
        <View style={styles.challengeCard}>
          <Text style={styles.challengeText}>{weeklyData.weeklyChallenge}</Text>
        </View>
      </View>

      {/* Podium Vehicle */}
      <View style={styles.vehicleSection}>
        <Text style={styles.sectionTitle}>Podium Vehicle</Text>
        <View style={styles.vehicleCard}>
          <Image 
            source={{ uri: getVehicleImage(weeklyData.podiumVehicle) }}
            style={styles.vehicleImage}
            defaultSource={require('@/assets/images/temp.png')}
          />
          <Text style={styles.vehicleName}>{weeklyData.podiumVehicle}</Text>
        </View>
      </View>

      {/* Prize Ride Vehicle */}
      <View style={styles.vehicleSection}>
        <Text style={styles.sectionTitle}>Prize Ride Vehicle</Text>
        <View style={styles.vehicleCard}>
          <Image 
            source={{ uri: getVehicleImage(weeklyData.prizeRideVehicle) }}
            style={styles.vehicleImage}
            defaultSource={require('@/assets/images/temp.png')}
          />
          <Text style={styles.vehicleName}>{weeklyData.prizeRideVehicle}</Text>
          <Text style={styles.challengeSubtext}>{weeklyData.prizeRideChallenge}</Text>
        </View>
      </View>

      {/* Time Trials */}
      <View style={styles.listSection}>
        <Text style={styles.sectionTitle}>Time Trials</Text>
        <View style={styles.listItem}>
          <Text style={styles.listLabel}>Time Trial:</Text>
          <Text style={styles.listValue}>{weeklyData.timeTrial}</Text>
        </View>
        <View style={styles.listItem}>
          <Text style={styles.listLabel}>HSW Time Trial:</Text>
          <Text style={styles.listValue}>{weeklyData.hswTimeTrial}</Text>
        </View>
      </View>

      {/* Salvage Yard Robberies */}
      <View style={styles.carouselSection}>
        <Text style={styles.carouselSectionTitle}>Salvage Yard Robberies</Text>
        <FlatList
          horizontal
          data={weeklyData.salvageYardRobberies}
          keyExtractor={(item, index) => index.toString()}
          showsHorizontalScrollIndicator={false}
          snapToInterval={width - 40}
          decelerationRate="fast"
          contentContainerStyle={styles.carouselContent}
          renderItem={({ item }) => (
            <View style={styles.carouselCard}>
              <Image 
                source={{ uri: getVehicleImage(item.vehicle) }}
                style={styles.carouselImage}
                defaultSource={require('@/assets/images/temp.png')}
              />
              <View style={styles.carouselInfo}>
                <Text style={styles.robberyType}>{item.type}</Text>
                <Text style={styles.robberyVehicle}>{item.vehicle}</Text>
              </View>
            </View>
          )}
        />
      </View>
      <Text style={styles.weekText}>{weeklyData.weekOf}</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
  },
  loadingText: {
    color: '#ffffff',
    fontSize: 18,
    textAlign: 'center',
    marginTop: 100,
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
    padding: 20,
  },
  challengeSection: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 12,
    fontFamily: Fonts.rounded,
  },
  challengeCard: {
    backgroundColor: '#2a2a2a',
    padding: 16,
    borderRadius: 8,
  },
  challengeText: {
    fontSize: 16,
    color: '#ffffff',
    lineHeight: 24,
  },
  vehicleSection: {
    padding: 20,
    paddingTop: 10,
  },
  vehicleCard: {
    backgroundColor: '#2a2a2a',
    borderRadius: 8,
    overflow: 'hidden',
    alignItems: 'center',
  },
  vehicleImage: {
    width: '100%',
    height: 200,
    resizeMode: 'cover',
  },
  vehicleName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
    padding: 16,
    paddingBottom: 8,
    textAlign: 'center',
  },
  vehiclePrice: {
    fontSize: 16,
    color: '#4ade80',
    paddingBottom: 16,
  },
  challengeSubtext: {
    fontSize: 14,
    color: '#888888',
    paddingHorizontal: 16,
    paddingBottom: 16,
    textAlign: 'center',
  },
  listSection: {
    padding: 20,
    paddingTop: 10,
  },
  listItem: {
    backgroundColor: '#2a2a2a',
    padding: 16,
    borderRadius: 8,
    marginBottom: 10,
  },
  listLabel: {
    fontSize: 14,
    color: '#888888',
    marginBottom: 4,
  },
  listValue: {
    fontSize: 16,
    fontWeight: '600',
    color: '#ffffff',
  },
  carouselSection: {
    paddingVertical: 20,
  },
  carouselSectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 12,
    fontFamily: Fonts.rounded,
    paddingHorizontal: 20,
  },
  carouselContent: {
    paddingLeft: 20,
  },
  carouselCard: {
    width: width - 60,
    marginRight: 20,
    backgroundColor: '#2a2a2a',
    borderRadius: 8,
    overflow: 'hidden',
  },
  carouselImage: {
    width: '100%',
    height: 180,
    resizeMode: 'cover',
  },
  carouselInfo: {
    padding: 16,
  },
  robberyType: {
    fontSize: 14,
    color: '#888888',
    marginBottom: 4,
  },
  robberyVehicle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 8,
  },
  robberyPrice: {
    fontSize: 16,
    color: '#4ade80',
  },
  introText: {
    fontSize: 14,
    color: '#ffffff',
    marginBottom: 8,
  },
  introSection : {
    padding: 20,
  }
});