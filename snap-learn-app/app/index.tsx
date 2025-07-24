import React from "react";
import { Text, View } from "react-native";
import "./global.css";

export default function Index() {
  return (
    // <ScrollView
    //   contentContainerStyle={{
    //     flex: 1,
    //     justifyContent: "center",
    //     alignItems: "center",
    //   }}
    // >
    //   <Text>Edit app/index.tsx to edit this screen.</Text>
    // </ScrollView>
    <View className="flex-1 items-center justify-center bg-white">
      <Text className="text-xl font-bold text-blue-500">
        Tailwind of the project
      </Text>
    </View>
  );
}
