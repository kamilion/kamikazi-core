#!/bin/bash

echo "Building Clean ISO from lubuntu-14.10-amd64.iso"

# First, Since we'll be removing apport and whoopsie...
# Whoopsie will fail to uninstall due to this file being missing.
echo -e '#!/bin/bash\nexit 0\n' > /etc/init.d/whoopsie
# Mark it executable. Remember to remove this during ISO cleanup.
chmod +x /etc/init.d/whoopsie
