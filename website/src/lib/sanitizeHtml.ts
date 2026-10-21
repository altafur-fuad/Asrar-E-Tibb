/**
 * Asrar-e-Tibb: Clinical HTML Sanitizer & Formatter
 * 
 * Safely cleans rich clinical descriptions from generic monographs while preventing XSS.
 * Retains semantic elements: <p>, <strong>, <b>, <em>, <i>, <u>, <ul>, <ol>, <li>, <br>, <span>.
 * Strips scripts, iframes, styles, event handlers, and scraper artifacts (e.g. "... Read more" toggles).
 */

export function sanitizeClinicalHtml(rawHtml?: string | null): string {
  if (!rawHtml || typeof rawHtml !== 'string') {
    return '';
  }

  let html = rawHtml;

  // 1. Remove dangerous executable tags and contents
  html = html.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
  html = html.replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '');
  html = html.replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '');
  html = html.replace(/<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>/gi, '');
  html = html.replace(/<embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed>/gi, '');
  html = html.replace(/<form\b[^<]*(?:(?!<\/form>)<[^<]*)*<\/form>/gi, '');

  // 2. Remove scraper artifacts (e.g. duplicate min-str blocks & toggle spans)
  html = html.replace(/<div[^>]*class="[^"]*min-str\b[^"]*"[^>]*>[\s\S]*?<\/div>/gi, '');
  html = html.replace(/<span[^>]*class="[^"]*min-str-toggle\b[^"]*"[^>]*>[\s\S]*?<\/span>/gi, '');

  // 3. Strip all event handlers (onclick, onerror, onload, onmouseover, etc.)
  html = html.replace(/\s+on[a-z]+\s*=\s*(?:'[^']*'|"[^"]*"|[^\s>]+)/gi, '');

  // 4. Neutralize javascript: and vbscript: URIs
  html = html.replace(/(href|src)\s*=\s*(['"])\s*(?:javascript|vbscript|data):[\s\S]*?\2/gi, '$1="#"');

  // 5. Remove unwanted structural wrappers but preserve their inner contents
  html = html.replace(/<\/?(?:div|section|article)[^>]*>/gi, '<br />');

  // 6. Clean up consecutive <br /> tags
  html = html.replace(/(?:<br\s*\/?>\s*){3,}/gi, '<br /><br />');

  // 7. Strip inline style attributes that override our theme or hide text
  html = html.replace(/\s+style\s*=\s*(?:'[^']*'|"[^"]*")/gi, '');

  return html.trim();
}
