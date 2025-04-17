// apps/in-pages/src/main.ts
import './style.css'; // 引入 CSS 文件 (下一步创建)

const appElement = document.querySelector<HTMLDivElement>('#app');

if (appElement) {
  appElement.innerHTML = `
    <h1>in-pages App</h1>
    <p>This is a minimal app structure to test the CI pipeline.</p>
    <p>Build and Deployment should pass.</p>
  `;
} else {
  console.error('Fatal Error: Could not find #app element in index.html');
}

console.log('in-pages main.ts initialized successfully!');
