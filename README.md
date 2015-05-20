# Upgrading to capacitor > 0.2.x from capacitor < 0.2.x

Stores now use immutable js for the data. The API is still the same but the data returned is now instances of immutable's classes. See https://github.com/facebook/immutable-js for usage. Unfortunately this completely break backwards compatibility. This might change from 0.2.x to 0.3.x so use at your own risk while we test how well it works.

# WIP
Another Flux implentation. More to come.

# Dependencies
lodash
immutable-js

## Credits
Action concept from https://github.com/AlexGalays/fluxx
