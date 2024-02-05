import * as React from 'react';
import { Button, View, Text, NativeAppEventEmitter } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import MapView from '../MapstedView/MapView';
import { useEffect, useState } from 'react';

function Details({ navigation }) {
    const [unloadMap, setUnloadMap] = useState(false)
    const [showMap, setShowMap] = useState(true)
    useEffect(() => {
        // when swipe back to previous page
        navigation.addListener('beforeRemove', () => {
            NativeAppEventEmitter.emit('refreshMapsted')
        })
        return () => {
            navigation.removeListener('beforeRemove')
        }
    }, [])
    const onUnloadCallback = (event) => {
        // Do stuff with event.region.latitude, etc.
        console.log('===mapsted unload success! ' + JSON.stringify(event))
        if (unloadMap) {
            setShowMap(false)
            navigation.goBack()
        }
    }
  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
      <Text>Detail Screen</Text>
      <Button
        title="Go back to home"
        onPress={() => {
            setUnloadMap(true)
        }}
      />
      {showMap && 
      <View style={{ width: 350, height: 600 }}>
        <MapView style={{ width: '100%', height: '100%' }} 
            propertyId={504}
            unloadMap={unloadMap}
            onUnloadCallback={onUnloadCallback}
        />
      </View>}
    </View>
  );
}

// ... other code from the previous section
export default Details