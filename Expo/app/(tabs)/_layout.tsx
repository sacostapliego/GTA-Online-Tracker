import { Tabs } from 'expo-router';
import React from 'react';

import { HapticTab } from '@/components/haptic-tab';
import { IconSymbol } from '@/components/ui/icon-symbol';
import { Colors } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import FontAwesome6 from '@expo/vector-icons/FontAwesome6';

export default function TabLayout() {

  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: Colors['dark'].tint,
        headerShown: false,
        tabBarButton: HapticTab,
      }}>
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color }) => <IconSymbol size={28} name="house.fill" color={color} />,
        }}
      />
      <Tabs.Screen
        name="bonuses"
        options={{
          title: 'Bonuses',
          tabBarIcon: ({ color }) => <MaterialIcons  size={28} name="attach-money" color={color} />,
        }}
      />
      <Tabs.Screen
        name="discounts"
        options={{
          title: 'Discounts',
          tabBarIcon: ({ color }) => <MaterialIcons size={28} name="discount" color={color} />,
        }}
      />
    </Tabs>
  );
}
