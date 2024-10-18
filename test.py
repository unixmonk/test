import html
import re

mystring = """
Here's a simple "Hello, World!" program in JavaScript:

```javascript
console.log("Hello, World!");
```

This code will print "Hello, World!" to the console.

If you want to display it on a web page, you can use this HTML and JavaScript:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Hello World</title>
</head>
<body>
    <script>
        document.write("Hello, World!");
    </script>
</body>
</html>
```
"""
pattern = r'```[\w+\-]*\s*\n?(.*?)\n?```'
cleaned_string = re.sub(pattern, r'\1', mystring, flags=re.DOTALL)
str=html.escape(cleaned_string)
print (str.strip())


