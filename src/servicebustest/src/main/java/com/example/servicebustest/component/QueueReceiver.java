package com.example.servicebustest.component;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

@Component
public class QueueReceiver {
    private static final String QUEUE_NAME = "servicebusperftestjavaqueue";
    private static final Logger logger = LoggerFactory.getLogger(QueueReceiver.class);

    @JmsListener(destination = QUEUE_NAME, containerFactory = "jmsListenerContainerFactory")
    public void receiveMessage(String message) {
        logger.info("Received message: {}", message);
    }
}
