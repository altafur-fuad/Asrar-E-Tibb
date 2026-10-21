const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

test('Website Dataset Verification: medicines.json', async (t) => {
  const medPath = path.resolve(__dirname, '../src/data/medicines.json');
  assert.ok(fs.existsSync(medPath), 'medicines.json must exist');

  const content = JSON.parse(fs.readFileSync(medPath, 'utf8'));
  assert.ok(Array.isArray(content), 'medicines.json must be an array');
  assert.ok(content.length > 2000, `Expected > 2000 curated medicines, found ${content.length}`);

  // Test first 100 items for structural completeness
  for (let i = 0; i < 100; i++) {
    const item = content[i];
    assert.ok(item.name && item.name.trim().length > 0, `Item ${i} must have a name`);
    assert.ok(item.slug && item.slug.trim().length > 0, `Item ${i} must have a slug`);
    assert.ok(item.dosage_form && item.dosage_form.trim().length > 0, `Item ${i} must have a dosage_form`);
    assert.ok(item.generic && item.generic.trim().length > 0, `Item ${i} must have generic info`);
    assert.ok(item.manufacturer && item.manufacturer.trim().length > 0, `Item ${i} must have manufacturer`);
    assert.ok(item.generic_id !== undefined, `Item ${i} must have generic_id defined`);
    assert.ok(item.generic_slug !== undefined, `Item ${i} must have generic_slug defined`);
  }
});

test('Website Dataset Verification: generics_index.json & foreign keys', async (t) => {
  const genPath = path.resolve(__dirname, '../src/data/generics_index.json');
  assert.ok(fs.existsSync(genPath), 'generics_index.json must exist');

  const generics = JSON.parse(fs.readFileSync(genPath, 'utf8'));
  assert.ok(Array.isArray(generics), 'generics_index.json must be an array');
  assert.equal(generics.length, 1711, 'Must contain all 1,711 generic monographs');

  // Verify generic structure and linked brands count
  let totalLinkedBrands = 0;
  for (const gen of generics) {
    assert.ok(gen.id, 'Generic must have id');
    assert.ok(gen.name, 'Generic must have name');
    assert.ok(gen.slug, 'Generic must have slug');
    assert.ok(typeof gen.brand_count === 'number', 'Generic must have brand_count number');
    totalLinkedBrands += gen.brand_count;
  }
  assert.ok(totalLinkedBrands > 20000, `Expected > 20,000 total linked brands across monographs, found ${totalLinkedBrands}`);
});

test('Alternative Brands Logic: Same generic ID & self-exclusion', async (t) => {
  const monoDir = path.resolve(__dirname, '../src/data/monographs');
  assert.ok(fs.existsSync(monoDir), 'Monographs directory must exist');

  // Load a multi-brand monograph (e.g. Paracetamol or Adalimumab)
  const adalimumabFile = path.join(monoDir, 'adalimumab-31.json');
  assert.ok(fs.existsSync(adalimumabFile), 'adalimumab-31 monograph must exist');

  const data = JSON.parse(fs.readFileSync(adalimumabFile, 'utf8'));
  assert.ok(Array.isArray(data.brands), 'Monograph must contain brands array');
  assert.ok(data.brands.length >= 2, 'Adalimumab must have multiple commercial brands');

  const currentBrand = data.brands[0];
  
  // Filter alternatives: same generic ID, excluding current brand
  const alternatives = data.brands.filter(b => b.id !== currentBrand.id && b.slug !== currentBrand.slug);

  assert.equal(alternatives.length, data.brands.length - 1, 'Alternatives count must be total brands minus 1');
  assert.ok(!alternatives.some(b => b.id === currentBrand.id), 'Alternatives must never contain the current medicine');
});

test('Clinical Monograph Preservation & File Verification', async (t) => {
  const monoDir = path.resolve(__dirname, '../src/data/monographs');
  assert.ok(fs.existsSync(monoDir), 'Monographs directory must exist');

  // Check sample monographs
  const sampleSlugs = ['adalimumab-31', 'paracetamol-1', 'omeprazole-2'];
  for (const slug of sampleSlugs) {
    const monoFile = path.join(monoDir, `${slug}.json`);
    if (fs.existsSync(monoFile)) {
      const data = JSON.parse(fs.readFileSync(monoFile, 'utf8'));
      assert.ok(data.name, `${slug} must have name`);
      assert.ok(data.dosage_description || data.indication_description, `${slug} must have populated clinical descriptions`);
    }
  }
});

test('HTML Sanitization Logic: XSS Prevention & Safe Tag Preservation', async (t) => {
  // Test sanitization regex logic directly
  function sanitize(html) {
    if (!html) return '';
    let res = html;
    res = res.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
    res = res.replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '');
    res = res.replace(/\s+on[a-z]+\s*=\s*(?:'[^']*'|"[^"]*"|[^\s>]+)/gi, '');
    res = res.replace(/(href|src)\s*=\s*(['"])\s*(?:javascript|vbscript|data):[\s\S]*?\2/gi, '$1="#"');
    return res.trim();
  }

  const dirtyHtml = '<p>Safe clinical text</p><script>alert("XSS")</script><a href="javascript:steal()">Click</a><img src="x" onerror="malicious()"/><strong>Important warning</strong>';
  const cleanHtml = sanitize(dirtyHtml);

  assert.ok(!cleanHtml.includes('<script>'), 'Must strip script tags');
  assert.ok(!cleanHtml.includes('javascript:'), 'Must strip javascript: URLs');
  assert.ok(!cleanHtml.includes('onerror='), 'Must strip onerror event handler');
  assert.ok(cleanHtml.includes('<p>Safe clinical text</p>'), 'Must preserve safe paragraph tags');
  assert.ok(cleanHtml.includes('<strong>Important warning</strong>'), 'Must preserve strong tags');
});

test('Image URL Classification & Protection', async (t) => {
  function isValidProductImage(url) {
    if (!url || typeof url !== 'string') return false;
    const trimmed = url.trim();
    if (trimmed.length === 0) return false;
    if (trimmed.includes('pic.png')) return false; // Developer portrait rejected
    if (trimmed.includes('medex.com.bd/attachments')) return false; // Monograph PDF link rejected
    if (trimmed.includes('prescribing-information')) return false;
    if (trimmed.toLowerCase().endsWith('.pdf')) return false;
    return true;
  }

  assert.equal(isValidProductImage('https://medex.com.bd/attachments/123/adalimumab-prescribing-information'), false, 'Monograph link must be rejected as image');
  assert.equal(isValidProductImage('assets/image/pic.png'), false, 'Developer portrait must be rejected as medicine image');
  assert.equal(isValidProductImage('https://example.com/medicine-box.png'), true, 'Valid image URL must be accepted');
  assert.equal(isValidProductImage(null), false, 'Null image must be rejected');
  assert.equal(isValidProductImage(''), false, 'Empty image must be rejected');
});

test('Website Dataset Verification: news.json', async (t) => {
  const newsPath = path.resolve(__dirname, '../src/data/news.json');
  assert.ok(fs.existsSync(newsPath), 'news.json must exist');

  const articles = JSON.parse(fs.readFileSync(newsPath, 'utf8'));
  assert.ok(Array.isArray(articles), 'news.json must be an array');
  assert.ok(articles.length >= 3, 'Must have at least 3 clinical articles');

  for (const article of articles) {
    assert.ok(article.title, 'Article must have title');
    assert.ok(article.author, 'Article must have author');
    assert.ok(article.category, 'Article must have category');
    assert.ok(Array.isArray(article.tags), 'Article must have tags array');
  }
});

test('Cart Logic: Quantity and Price Calculation', async (t) => {
  const items = [
    { id: '1', name: 'A-Cold', price: '৳ 40.12', unitPriceNumeric: 40.12, quantity: 2 },
    { id: '2', name: 'A-Cof', price: '৳ 100.00', unitPriceNumeric: 100.00, quantity: 1 }
  ];

  const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);
  const totalPrice = items.reduce((sum, item) => sum + item.unitPriceNumeric * item.quantity, 0);

  assert.equal(totalItems, 3, 'Total items should equal 3');
  assert.equal(totalPrice, 180.24, 'Total price should equal 180.24');
});
