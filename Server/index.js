var mosca = require('mosca');

var settings = {
    persistence: {
        factory: mosca.persistence.Mongo,
        url: 'mongodb://localhost:27017/mqtt',
    },
    backend: {
        type: 'mongo',
        url: 'mongodb://localhost:27017/mqtt',
        pubsubCollection: 'ascoltatori',
        mongo: {}
    }
};

var server = new mosca.Server(settings);

server.on('ready', function() {
    console.log('Mosca server is up and running.')
});

server.on('clientConnected', function(client) {
    console.log('client connected', client.id);
});

server.on('published', function(packet, client) {
    console.log('Published', packet.payload);
    if (client !== undefined && client !== null) {
        console.log("\tclient",client.id);  
    }
});