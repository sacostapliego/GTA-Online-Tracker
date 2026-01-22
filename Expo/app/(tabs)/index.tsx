import { StyleSheet, ScrollView, View, Text, Image } from 'react-native';
import { useEffect, useState } from 'react';
import { Fonts } from '@/constants/theme';

interface WeeklyData {
  weekOf: string;
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

const DEFAULT_IMAGE = 'https://static.wikia.nocookie.net/gtawiki/images/5/50/GTAOnlineWebsite-ScreensPC-589-3840.jpg/revision/latest/scale-to-width-down/1000?cb=20210629175043';

export default function HomeScreen() {
  const [weeklyData, setWeeklyData] = useState<WeeklyData | null>(null);

  useEffect(() => {
    const data = require('@/assets/data/weekly-update.json');
    setWeeklyData(data);
  }, []);

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
        <Text style={styles.weekText}>{weeklyData.weekOf}</Text>
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
            source={{ uri: DEFAULT_IMAGE }}
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
            source={{ uri: DEFAULT_IMAGE }}
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
      <View style={styles.listSection}>
        <Text style={styles.sectionTitle}>Salvage Yard Robberies</Text>
        {weeklyData.salvageYardRobberies.map((robbery, index) => (
          <View key={index} style={styles.listItem}>
            <Text style={styles.listLabel}>{robbery.type}:</Text>
            <Text style={styles.listValue}>{robbery.vehicle}</Text>
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
    textAlign: 'center',
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
});