#!/bin/bash

# Create index.html
echo "Creating configuration files for the Kiosk..."
echo "Creating index.html..."
cat > /apps/${APP_NAME}/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Kiosk Browser</title>
    <script>
        window.location.href = "${KIOSK_URL}";
    </script>
</head>
<body>
    <h1>Hello!</h1>
    <p>Redirecting to the URL provided in the KIOSK_URL environment variable...</p>
</body>
</html>
EOF

# Create package.json
echo "Creating package.json..."
cat > /apps/${APP_NAME}/package.json << EOF
{
    "name": "kiosk",
    "version": "1.0.0",
    "main": "index.html",
    "window": {
        "kiosk": true,
        "frame": true,
        "position": "center",
        "width": 1024,
        "height": 768
    }
}
EOF

echo "Done."