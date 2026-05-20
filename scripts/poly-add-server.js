const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const CONTEXT = 'greenLogisticsOptimizer';
const BASE_DIR = path.join(__dirname, '..', 'src', 'serverFunctions');

function getTsFiles(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const files = fs.readdirSync(dir);
  files.forEach(file => {
    const filePath = path.join(dir, file);
    if (fs.statSync(filePath).isDirectory()) {
      getTsFiles(filePath, fileList);
    } else if (file.endsWith('.ts') && file !== 'index.ts') {
      fileList.push(filePath);
    }
  });
  return fileList;
}

const tsFiles = getTsFiles(BASE_DIR);

tsFiles.forEach(absolutePath => {
  const functionName = path.basename(absolutePath, '.ts');  
  
  // This forces the path to look exactly like your manual command: ./src/serverFunctions/...
  const relativePath = './src/serverFunctions/' + path.relative(BASE_DIR, absolutePath);  

  // Your exact manual command format
  const command = `npx poly function add ${functionName} ${relativePath} --context "${CONTEXT}" --server`;  

  console.log(`📦 Running: ${command}`);
  try {
    execSync(command, { stdio: 'inherit' });
  } catch (error) {
    // Error output will show automatically due to stdio: 'inherit'
  }
});