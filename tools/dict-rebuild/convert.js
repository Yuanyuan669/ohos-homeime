// rime pinyin_simp -> AOSP PinyinIME rawdict (UTF-16LE)
// 行格式: 词\t频率\tGBK标志\t拼音1 拼音2 ...
const fs = require('fs');
const path = require('path');
const dir = __dirname;

// OpenCC TSCharacters 的 key 都是有简化对应的繁体字，含这类字的词条丢弃
const trad = new Set();
for (const line of fs.readFileSync(path.join(dir, 'TSCharacters.txt'), 'utf8').split('\n')) {
  if (line.startsWith('#') || !line.trim()) continue;
  const key = line.split('\t')[0];
  if ([...key].length === 1) trad.add(key);
}

// 现有引擎的合法汉字集
const buf = fs.readFileSync('D:/ohos/ohos-homeime/entry/src/main/cpp/data/valid_utf16.txt');
let validStr = '';
for (let i = (buf[0] === 0xff && buf[1] === 0xfe ? 2 : 0); i + 1 < buf.length; i += 2) {
  validStr += String.fromCharCode(buf.readUInt16LE(i));
}
const valid = new Set(validStr.replace(/\s/g, '').split(''));

const yaml = fs.readFileSync(path.join(dir, 'pinyin_simp.dict.yaml'), 'utf8');
const outLines = [];
let droppedTrad = 0, droppedValid = 0, droppedLong = 0, droppedLow = 0, droppedSyl = 0;
const seen = new Set();

for (const line of yaml.split('\n')) {
  if (!line || line.startsWith('#') || line.startsWith('---') || line.startsWith('...') || line.includes(':')) continue;
  const parts = line.split('\t');
  if (parts.length < 3) continue;
  const word = parts[0];
  const sylls = parts[1].trim().split(/\s+/);
  const weight = parseInt(parts[2], 10);
  const chars = [...word];
  if (chars.length !== sylls.length) { droppedSyl++; continue; }
  if (chars.some(c => trad.has(c))) { droppedTrad++; continue; }
  if (chars.some(c => !valid.has(c))) { droppedValid++; continue; }
  if (chars.length > 4) { droppedLong++; continue; }
  if (chars.length > 1 && weight < 60) { droppedLow++; continue; }
  if (sylls.some(s => !/^[a-z]+$/.test(s) || s.length > 6)) { droppedSyl++; continue; }
  const key = word + '|' + parts[1].trim();
  if (seen.has(key)) continue;
  seen.add(key);
  outLines.push(word + '\t' + weight + '\t0\t' + sylls.join(' '));
}

// 频率高的排前面，单字全保留（与现有词典行为一致）
const single = outLines.filter(l => [...l.split('\t')[0]].length === 1);
const multi = outLines.filter(l => [...l.split('\t')[0]].length > 1)
  .sort((a, b) => parseInt(b.split('\t')[1]) - parseInt(a.split('\t')[1]));
const final = single.concat(multi);

let u16 = [0xfeff];
for (const l of final) {
  for (const cu of l) u16.push(cu.codePointAt(0));
  u16.push(0x0a);
}
const ob = Buffer.alloc(u16.length * 2);
for (let i = 0; i < u16.length; i++) ob.writeUInt16LE(u16[i] & 0xffff, i * 2);
fs.writeFileSync(path.join(dir, 'rawdict_phrases.txt'), ob);

console.log('kept:', final.length, '(single:', single.length, 'multi:', multi.length + ')');
console.log('dropped trad:', droppedTrad, 'invalid-hz:', droppedValid, 'too-long:', droppedLong, 'low-freq:', droppedLow, 'bad-pinyin:', droppedSyl);
