/**
 * @description Mapsted view
 * @author Jiaxiang Wang
 * @date 2024-01-02
 */
import PropTypes from 'prop-types'
import React from 'react'
import { requireNativeComponent } from 'react-native'

class MapstedView extends React.Component {
    _onLoadCallback = (event) => {
        if (!this.props.onLoadCallback) {
            return
        }
        // process raw event...
        this.props.onLoadCallback(event.nativeEvent)
    }

    _onSelectLocation = (event) => {
        if (!this.props.onSelectLocation) {
            return
        }
        // process raw event...
        this.props.onSelectLocation(event.nativeEvent)
    }

    _onUnloadCallback = (event) => {
        if (!this.props.onUnloadCallback) {
            return
        }
        // process raw event...
        this.props.onUnloadCallback(event.nativeEvent)
    }

    render() {
        return (
            <RNTMap
                {...this.props}
                onLoadCallback={this._onLoadCallback}
                onSelectLocation={this._onSelectLocation}
                onUnloadCallback={this._onUnloadCallback}
            />
        )
    }
}

MapstedView.propTypes = {
    // property id
    propertyId: PropTypes.number,
    unloadMap: PropTypes.bool,
    onLoadCallback: PropTypes.func,
    onSelectLocation: PropTypes.func,
    onUnloadCallback: PropTypes.func
}

const RNTMap = requireNativeComponent('RNTMap', MapstedView)

export default MapstedView
