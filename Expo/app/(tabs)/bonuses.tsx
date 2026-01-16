import { StyleSheet, ScrollView, View, Text } from 'react-native';
import { useEffect, useState } from 'react';
import { Fonts } from '@/constants/theme';

interface WeeklyData {
  weekOf: string;
  bonuses: string[];
}

export default function BonusesTab() {
  const [weeklyData, setWeeklyData] = useState<WeeklyData | null>(null);

  useEffect(() => {
    // TODO/TEMPORARY: Load local JSON data from copying weekly-update.json to assets folder
    const data = require('@/assets/data/weekly-update.json');
    setWeeklyData(data);
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
        {weeklyData?.bonuses.map((bonus, index) => (
          <View key={index} style={styles.bonusItem}>
            <Text style={styles.bulletPoint}>•</Text>
            <Text style={styles.bonusText}>{bonus}</Text>
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
    padding: 16,
  },
  bonusItem: {
    flexDirection: 'row',
    padding: 12,
    marginBottom: 12,
    alignItems: 'flex-start',
    gap: 8,
  },
  bulletPoint: {
    fontSize: 18,
    lineHeight: 24,
    color: '#ffffff',
  },
  bonusText: {
    flex: 1,
    fontSize: 16,
    lineHeight: 24,
    color: '#ffffff',
  },
});