import fs from 'fs';
import path from 'path';
import t from 'tap';

// resolve paths to package.json files
const rootPkgPath = path.resolve('./package.json');
const webPkgPath = path.resolve('./web/package.json');

// read & parse JSON
const rootPkg = JSON.parse(fs.readFileSync(rootPkgPath, 'utf-8'));
const webPkg = JSON.parse(fs.readFileSync(webPkgPath, 'utf-8'));

// tap test
t.test('package.json versions are consistent', t => {
  t.equal(
    webPkg.version,
    rootPkg.version,
    `web/package.json version (${webPkg.version}) should match root package.json version (${rootPkg.version})`
  );
  t.end();
});
