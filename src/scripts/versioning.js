/**
 * Script to version files
 */
const fs = require('fs');
const path = require('path');
const process = require('process');
const { EOL } = require('os');

// file paths
const sonarPropertiesPath = './sonar-project.properties';
const envPath = './environment.js';
const packageJsonPath = './package.json';
// strings to match in files
const sonarVersion = 'sonar.projectVersion=';
const envVersion = 'version:';

// THE TERMINATOR
const exit = (code) => {
    console.info(`Process ended with exit code ${code}`);
    process.exit(code);
};

// helper to get version from package.json
const getCurrentVersion = () => {
    let content;
    try {
        const packageContents = fs.readFileSync(path.resolve(packageJsonPath), 'utf-8');
        content = JSON.parse(packageContents);
    } catch ( e ) {
        console.error('Failed to read version from package.json >>>', e.message);
        exit(1);
    }
    return content.version;
};

// helper to read and edit file content
const updateFileVersion = (filePath, searchTerm, separator, version, wrap = false) => {
    try {
        const fileContent = fs.readFileSync(path.resolve(filePath), 'utf-8'); // can throw
        const lines = fileContent.split(EOL);
        const regex = new RegExp(searchTerm, 'gi');
        const updatedLines = lines.map(line => {
            if (regex.test(line)) {
                const end = line.indexOf(separator);
                return wrap ?
                    `${line.substring(0, end)}${separator}'${version}',`
                        :
                    `${line.substring(0, end)}${separator}${version}`;
            }
            return line;
        });
        const updatedContent = updatedLines.join(EOL);
        fs.writeFileSync(filePath, updatedContent); // can throw
        console.info(`Updated version successfully in "${filePath}"`);
    } catch ( e ) {
        console.error(`Failed to update version in "${filePath}" >>>`, e.message);
        exit(1);
    }
};

// get version from package.json and update in sonar & env
const version = getCurrentVersion();
updateFileVersion(sonarPropertiesPath, sonarVersion, '=', version);
updateFileVersion(envPath, envVersion, ': ', version, true);
exit(0); // success
