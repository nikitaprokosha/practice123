#!/usr/bin/env bash
set -e

echo "Генерация статического сайта..."

# Создаём директорию для сайта
mkdir -p public

# Копируем все markdown файлы
cp README.md public/index.md
cp -r levels public/
cp STRUCTURE.md public/ 2>/dev/null || true
cp AGENTS.md public/ 2>/dev/null || true

# Создаём Python-скрипт для конвертации
cat > /tmp/md2html.py << 'ENDOFPYTHON'
import os
import re

CSS = """
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; max-width: 900px; margin: 0 auto; padding: 20px; background: #f5f5f5; }
h1, h2, h3 { color: #333; }
a { color: #0366d6; }
pre { background: #2d2d2d; color: #f8f8f2; padding: 15px; border-radius: 5px; overflow-x: auto; }
code { background: #e8e8e8; padding: 2px 6px; border-radius: 3px; font-family: 'Consolas', 'Monaco', monospace; }
pre code { background: none; padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 20px 0; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background: #4a90d9; color: white; }
tr:nth-child(even) { background: #f9f9f9; }
.nav { background: #4a90d9; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
.nav a { color: white; margin-right: 15px; text-decoration: none; }
.nav a:hover { text-decoration: underline; }
"""

def md_to_html(md_content):
    html = md_content
    
    # Заголовки
    html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)
    html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
    html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
    
    # Жирный текст
    html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
    html = re.sub(r'__ (.+?)__', r'<strong>\1</strong>', html)
    
    # Курсив
    html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
    
    # Ссылки
    html = re.sub(r'\[(.+?)\]\((.+?)\)', r'<a href="\2">\1</a>', html)
    
    # Код (блоки)
    html = re.sub(r'```(\w*)\n(.*?)```', r'<pre><code class="language-\1">\2</code></pre>', html, flags=re.DOTALL)
    
    # Код (инлайн)
    html = re.sub(r'`(.+?)`', r'<code>\1</code>', html)
    
    # Списки
    html = re.sub(r'^[-*] (.+)$', r'<li>\1</li>', html, flags=re.MULTILINE)
    html = re.sub(r'(<li>.*</li>\n?)+', lambda m: '<ul>\n' + m.group(0) + '</ul>\n', html)
    
    # Параграфы
    lines = html.split('\n')
    result = []
    in_paragraph = False
    for line in lines:
        stripped = line.strip()
        if stripped and not line.startswith('<') and not line.startswith('#') and not line.startswith('-') and not line.startswith('*') and not line.startswith('|') and not line.startswith('```') and not line.startswith('    '):
            if not in_paragraph:
                result.append('<p>')
                in_paragraph = True
            result.append(line)
        else:
            if in_paragraph:
                result.append('</p>')
                in_paragraph = False
            result.append(line)
    
    return '\n'.join(result)

def wrap_html(title, content):
    template = """<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>{css}</style>
</head>
<body>
    <nav class="nav">
        <a href="/">Главная</a>
        <a href="/levels/0/">Уровень 0</a>
        <a href="/levels/1/">Уровень 1</a>
        <a href="/STRUCTURE.html">Архитектура</a>
        <a href="/AGENTS.html">Для агента</a>
    </nav>
    <main>
    {content}
    </main>
</body>
</html>"""
    return template.format(title=title, css=CSS, content=content)

# Обработка файлов
for root, dirs, files in os.walk('public'):
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    
    for file in files:
        if file.endswith('.md'):
            md_path = os.path.join(root, file)
            html_path = md_path.replace('.md', '.html')
            
            with open(md_path, 'r', encoding='utf-8') as f:
                md_content = f.read()
            
            # Конвертируем ссылки
            md_content = re.sub(r'\.md\)', '.html)', md_content)
            
            html_content = md_to_html(md_content)
            title_match = re.search(r'^# (.+)$', md_content, re.MULTILINE)
            title = title_match.group(1) if title_match else 'Nix Training'
            
            html_output = wrap_html(title, html_content)
            
            with open(html_path, 'w', encoding='utf-8') as f:
                f.write(html_output)
            
            print(f"Сгенерировано: {html_path}")

print("Генерация сайта завершена!")
ENDOFPYTHON

python3 /tmp/md2html.py

echo "Сайт собран в директорию public/"
