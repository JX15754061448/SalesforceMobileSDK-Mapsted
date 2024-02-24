import * as React from 'react';
import { Button, View, Text, NativeAppEventEmitter } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import MapView from '../MapstedView/MapView';
import { useEffect, useState } from 'react';

function HomeScreen({ navigation }) {
    const [unloadMap, setUnloadMap] = useState(false)
    const [showMap, setShowMap] = useState(true)
    useEffect(() => {
        const mapstedListener = NativeAppEventEmitter.addListener('refreshMapsted', async () => {
            setUnloadMap(false)
            setShowMap(true)
        })
        return () => {
            mapstedListener && mapstedListener.remove()
        }
    }, [])
    const onUnloadCallback = (event) => {
        // Do stuff with event.region.latitude, etc.
        console.log('===mapsted unload success! ' + JSON.stringify(event))
        if (unloadMap) {
            setShowMap(false)
            navigation.navigate('Details')
        }
    }

  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Home Screen</Text>
      <Button
        title="Go to Details"
        onPress={() => {
            setUnloadMap(true)
        }}
      />
      {showMap && 
      <View style={{ width: 400, height: 400 }}>
        <MapView 
            style={{ width: '100%', height: '100%' }} 
            propertyId={1132}
            unloadMap={unloadMap}
            onUnloadCallback={onUnloadCallback}
        />
      </View>}
    </View>
  );
}

// ... other code from the previous section
export default HomeScreen