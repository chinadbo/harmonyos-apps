const fs = require('fs')
const path = require('path')
const assert = require('assert')

const appJson5Path = path.resolve(__dirname, '..', 'AppScope', 'app.json5')
const content = fs.readFileSync(appJson5Path, 'utf8')
const config = JSON.parse(content)

assert.strictEqual(config.app.bundleName, 'com.example.harmonyclock')
console.log('app.json5 bundleName is correct')
