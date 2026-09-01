const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', timeout: 20000 });
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
  try {
    await page.goto('https://ocr-structuring-demo.demos.himitsuno-heya123.com', { timeout: 15000, waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    await page.screenshot({ path: '/tmp/test_shot.png' });
    console.log('SUCCESS');
  } catch (e) {
    console.log('FAILED:', e.message);
  }
  await browser.close();
  process.exit(0);
})();
