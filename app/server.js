const http = require('http');
const os = require('os');

const appName = process.env.APP_NAME;
const port = process.env.PORT;

const getIPAddress = () => {
    const interfaces = os.networkInterfaces();
    for (const devName in interfaces) {
        const iface = interfaces[devName];

        for (let i = 0; i < iface.length; i++) {
            const alias = iface[i];
            if (alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal)
                return alias.address;
        }
    }

    return '0.0.0.0';
};

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    const response = {
        appName: appName,
        port: port,
        ipAddress: getIPAddress(),
    };
    res.end(JSON.stringify(response));
});

server.listen(port, () => {
    console.log(`Server running at http://${getIPAddress()}:${port}/`);
});
