/**
 * Script to version files
 */
const fs = require('fs');
const path = require('path');
const { EOL } = require('os');

// file paths
const sonarProjectPath = './sonar-project.properties';
const envPath = './environment.js';
const packageJsonPath = './package.json';
// strings to match in files
const sonarVersion = 'sonar.projectVersion';
const envVersion = 'version:';

const getCurrentVersion = () => {
    let content;
    try {
        const packageContents = fs.readFileSync(path.resolve(packageJsonPath), 'utf-8');
        content = JSON.parse(packageContents);
    } catch ( e ) {
        console.error('Failed to read version from package.json', e);
    }
    return content && content.version;
};

const version = getCurrentVersion();

const updateSonarPropertiesFile = () => {
    const sonarProps = fs.readFileSync(path.resolve(sonarProjectPath), 'utf-8');
    const lines = sonarProps.split(EOL);
    const regex = new RegExp(sonarVersion, 'g');
    const updatedLines = lines.map(line => {
        if ( regex.test(line) ) {
            const end = line.indexOf('=') + 1;
            return line.substring(0, end) + version;
        }
        return line;
    });
    const updatedSonarProps = updatedLines.join(EOL);
    try {
        fs.writeFileSync(sonarProjectPath, updatedSonarProps);
        console.info(`Updated version successfully in "${sonarProjectPath}"`);
    } catch ( e ) {
        console.error(`Failed to update version in "${sonarProjectPath}"`, e);
    }
};

updateSonarPropertiesFile();

const updateEnvFile = () => {
    const env = fs.readFileSync(path.resolve(envPath), 'utf-8');
    const lines = env.split(EOL);
    const regex = new RegExp(envVersion, 'gi');
    const updatedLines = lines.map(line => {
        if ( regex.test(line) ) {
            const end = line.indexOf(':');
            return `${line.substring(0, end)}: '${version}',`;
        }
        return line;
    });
    const updatedEnv = updatedLines.join(EOL);
    try {
        fs.writeFileSync(envPath, updatedEnv);
        console.info(`Updated version successfully in ${envPath} file`);
    } catch ( e ) {
        console.error(`Failed to update version in "${envPath}"`, e);
    }

};

updateEnvFile();
