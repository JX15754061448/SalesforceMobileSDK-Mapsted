// MapView.js
import PropTypes from 'prop-types';
import React from 'react';
import { requireNativeComponent } from 'react-native';

class MapView extends React.Component {
  render() {
    return <RNTMap {...this.props} />;
  }
}

MapView.propTypes = {
  /**
   * A Boolean value that determines whether the user may use pinch
   * gestures to zoom in and out of the map.
   */
  // zoomEnabled: PropTypes.bool
  title: PropTypes.string
};

const RNTMap = requireNativeComponent('RNTMap', MapView);

export default MapView;