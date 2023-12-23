const express = require('express');
const { spawn } = require('child_process');

const fs = require('fs');
const app = express();

// Serve static files from the "public" directory
app.use(express.static('frontend/public/'));
   
// Set up middleware to parse incoming text data
app.use(express.text());

// Initialize files
fs.writeFile('runtime/coordinates.txt', "", (err) => { })
fs.writeFile('runtime/refreshmap.txt', "", (err) => { })

// Handle POST requests for /coordinates
app.post('/coordinates', (req, res) => {
    const textData = req.body.toString();
    fs.writeFile('runtime/coordinates.txt', textData, (err) => {
        if (err) {
            console.error(err);
            res.status(500).send('Server Error');
        } else {
            res.status(200).send('Coordinates written successfully');
        }
    });
});

// Handle POST requests for /refreshmap
app.post('/refreshmap', (req, res) => {
    const textData = req.body.toString();
    const textDataParts = textData.split(';');

    const child = spawn('scripts/syncMap.exe', [textDataParts[0], textDataParts[1], textDataParts[2]]);

    child.on('exit', (code) => {
        if (code === 0) {
            res.status(200).send('Refresh map written and executed successfully');
        } else {
            res.status(500).send('Failed to execute syncMap.exe');
        }
    });
});

// Start the server on port 3000
const PORT = 3000;
app.listen(PORT, () => {
});
