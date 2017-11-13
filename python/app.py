import watchtower
import logging
import time
import random
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
watchtowerHandler = watchtower.CloudWatchLogHandler(
    log_group=os.environ["AWS_LOG_GROUP"],
    stream_name=os.environ["AWS_LOG_STREAM"] + "/python",
)
logger.addHandler(watchtowerHandler)

gripes = [
    "My back hurts.",
    "This isn't third-wave coffee.",
    "This isn't my preferred brand of socks.",
    "There's a fly in my soup!",
    "Everything is too far way from everything else!",
    "Traffic was terrible this morning.",
    "My dog ate my homework!"
]

logger.info(f"Logging to log group \"{watchtowerHandler.log_group}\".")

while True:
    logger.info(random.choice(gripes))
    time.sleep(0.5)
