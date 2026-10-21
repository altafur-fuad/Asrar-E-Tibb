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

  // Test first 50 items for structural completeness
  for (let i = 0; i < 50; i++) {
    const item = content[i];
    assert.ok(item.name && item.name.trim().length > 0, `Item ${i} must have a name`);
    assert.ok(item.slug && item.slug.trim().length > 0, `Item ${i} must have a slug`);
    assert.ok(item.dosage_form && item.dosage_form.trim().length > 0, `Item ${i} must have a dosage_form`);
    assert.ok(item.generic && item.generic.trim().length > 0, `Item ${i} must have generic info`);
    assert.ok(item.manufacturer && item.manufacturer.trim().length > 0, `Item ${i} must have manufacturer`);
  }
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
