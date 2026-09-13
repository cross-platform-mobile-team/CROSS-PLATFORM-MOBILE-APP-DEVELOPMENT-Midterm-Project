"""Render all PDF pages and record headings/text for final visual inspection."""
from pathlib import Path
import argparse
import json
from pypdf import PdfReader
import pypdfium2 as pdfium

parser=argparse.ArgumentParser()
parser.add_argument('pdf')
parser.add_argument('out')
args=parser.parse_args()
out=Path(args.out); out.mkdir(parents=True,exist_ok=True)
reader=PdfReader(args.pdf)
doc=pdfium.PdfDocument(args.pdf)
records=[]
for i,page in enumerate(doc):
    text=reader.pages[i].extract_text()
    records.append({'physical_page':i+1,'start':text[:130], 'characters':len(text)})
    page.render(scale=1.25).to_pil().save(out/f'page-{i+1}.png')
(out/'page-index.json').write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding='utf-8')
(out/'text.txt').write_text('\n\n'.join(p.extract_text() for p in reader.pages),encoding='utf-8')
print(json.dumps({'pages':len(doc),'out':str(out)},indent=2))
