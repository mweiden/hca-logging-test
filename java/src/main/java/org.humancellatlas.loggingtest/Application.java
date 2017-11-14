package org.humancellatlas.loggingtest;

import java.util.Random;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;


class Application {

    static Logger logger = LogManager.getLogger(Application.class.getName());

    static String[] gripes = {
            "My back hurts.",
            "This isn't third-wave coffee.",
            "This isn't my preferred brand of socks.",
            "There's a fly in my soup!",
            "Everything is too far way from everything else!",
            "Traffic was terrible this morning.",
            "My dog ate my homework!"
    };

    public static void main(String[] args) throws java.lang.InterruptedException {
        Random randomizer = new Random();
        while (true) {
            logger.info(
                    gripes[randomizer.nextInt(gripes.length)]
            );
            Thread.sleep(500);
        }
    }
}