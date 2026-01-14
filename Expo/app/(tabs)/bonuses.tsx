import { StyleSheet } from 'react-native';
import { useEffect, useState } from 'react';

import ParallaxScrollView from '@/components/parallax-scroll-view';
import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { IconSymbol } from '@/components/ui/icon-symbol';
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
    <ParallaxScrollView
      headerBackgroundColor={{ light: '#D0D0D0', dark: '#353636' }}
      headerImage={
        <IconSymbol
          size={310}
          color="#808080"
          name="star.fill"
          style={styles.headerImage}
        />
      }>
      <ThemedView style={styles.titleContainer}>
        <ThemedText
          type="title"
          style={{
            fontFamily: Fonts.rounded,
          }}>
          Weekly Bonuses
        </ThemedText>
      </ThemedView>
      
      {weeklyData && (
        <>
          <ThemedText style={styles.weekText}>
            {weeklyData.weekOf}
          </ThemedText>

          <ThemedView style={styles.bonusesContainer}>
            {weeklyData.bonuses.map((bonus, index) => (
              <ThemedView key={index} style={styles.bonusItem}>
                <ThemedText style={styles.bulletPoint}>•</ThemedText>
                <ThemedText style={styles.bonusText}>{bonus}</ThemedText>
              </ThemedView>
            ))}
          </ThemedView>
        </>
      )}
    </ParallaxScrollView>
  );
}

const styles = StyleSheet.create({
  headerImage: {
    color: '#808080',
    bottom: -90,
    left: -35,
    position: 'absolute',
  },
  titleContainer: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 16,
  },
  weekText: {
    fontSize: 14,
    opacity: 0.7,
    marginBottom: 24,
  },
  bonusesContainer: {
    gap: 12,
  },
  bonusItem: {
    flexDirection: 'row',
    gap: 8,
    alignItems: 'flex-start',
  },
  bulletPoint: {
    fontSize: 18,
    lineHeight: 24,
  },
  bonusText: {
    flex: 1,
    fontSize: 16,
    lineHeight: 24,
  },
});