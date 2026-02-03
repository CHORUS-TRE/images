"""Script that sets up the environment for the AMLD notebook."""

import os

os.environ["NODE_URL"] = "https://amld-workshop-node1.demo.tuneinsight.net"
os.environ["OIDC_URL"] = "https://auth.tuneinsight.com/auth/"
os.environ["OIDC_CLIENT_ID"] = "amld1-front-8atme9aty9"
os.environ["TI_VERIFY_SSL"] = "False"
