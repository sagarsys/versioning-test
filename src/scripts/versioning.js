/**
 * Script to version files
 */
const fs = require('fs');
const path = require('path');
const { environment } = require('../../environment.js');

const sonarProject = './sonar-project.properties';
const env = './environment.js';
const packageJson = './package.json';


const getCurrentVersion = () => {
    const packageContents = fs.readFileSync(path.resolve(packageJson));
    let content;
    try {
        content = JSON.parse(packageContents);
    } catch (e) {
        console.log(e);
    }
    return content && content.version;
};

const version = getCurrentVersion();
const sonarProps = fs.readFileSync(path.resolve(env), 'utf-8');
console.log(environment);
environment.version = version;
console.log(environment);

console.log(sonarProps);


