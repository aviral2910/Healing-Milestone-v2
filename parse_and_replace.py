import os
import re

def parse_parentheses(text, start_index):
    open_count = 0
    for i in range(start_index, len(text)):
        if text[i] == '(':
            open_count += 1
        elif text[i] == ')':
            open_count -= 1
            if open_count == 0:
                return i
    return -1

def patch_file(filepath):
    if not os.path.exists(filepath):
        return False
        
    with open(filepath, 'r') as f:
        content = f.read()
        
    original_content = content
    
    # Needs import
    needs_import = False
    
    # 1. Replace NetworkImage
    search_idx = 0
    while True:
        idx = content.find("NetworkImage(", search_idx)
        if idx == -1:
            break
            
        end_idx = parse_parentheses(content, idx + 12)
        if end_idx != -1:
            needs_import = True
            inner_content = content[idx + 13:end_idx]
            # Replace with CachedNetworkImageProvider
            new_call = f"CachedNetworkImageProvider({inner_content}, maxHeight: 200)"
            content = content[:idx] + new_call + content[end_idx+1:]
            search_idx = idx + len(new_call)
        else:
            search_idx = idx + 12

    # 2. Replace Image.network
    search_idx = 0
    while True:
        idx = content.find("Image.network(", search_idx)
        if idx == -1:
            break
            
        end_idx = parse_parentheses(content, idx + 13)
        if end_idx != -1:
            needs_import = True
            inner_content = content[idx + 14:end_idx].strip()
            
            # Find the first comma that is at the root level of parentheses to separate the URL from other args
            url = ""
            rest = ""
            
            open_parens = 0
            open_braces = 0
            open_brackets = 0
            comma_idx = -1
            
            for i, char in enumerate(inner_content):
                if char == '(': open_parens += 1
                elif char == ')': open_parens -= 1
                elif char == '{': open_braces += 1
                elif char == '}': open_braces -= 1
                elif char == '[': open_brackets += 1
                elif char == ']': open_brackets -= 1
                elif char == ',' and open_parens == 0 and open_braces == 0 and open_brackets == 0:
                    comma_idx = i
                    break
            
            if comma_idx != -1:
                url = inner_content[:comma_idx].strip()
                rest = inner_content[comma_idx+1:].strip()
                
                # Check if memCacheWidth/Height are needed
                # Only add if it's not a tiny image (width: 48)
                if "width: " in rest and "height: " in rest:
                    new_call = f"CachedNetworkImage(imageUrl: {url}, {rest})"
                else:
                    new_call = f"CachedNetworkImage(imageUrl: {url}, memCacheWidth: 800, {rest})"
            else:
                url = inner_content
                new_call = f"CachedNetworkImage(imageUrl: {url}, memCacheWidth: 800)"
                
            content = content[:idx] + new_call + content[end_idx+1:]
            search_idx = idx + len(new_call)
        else:
            search_idx = idx + 13

    if needs_import and original_content != content:
        # Add import at the top
        if "import 'package:cached_network_image/cached_network_image.dart';" not in content:
            # find first import
            first_import = content.find("import ")
            if first_import != -1:
                content = content[:first_import] + "import 'package:cached_network_image/cached_network_image.dart';\n" + content[first_import:]
        
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Patched {filepath}")
        return True
        
    return False

# Find all dart files
import glob

patched_count = 0
for filepath in glob.glob('lib/**/*.dart', recursive=True):
    if patch_file(filepath):
        patched_count += 1

print(f"Total files patched: {patched_count}")
