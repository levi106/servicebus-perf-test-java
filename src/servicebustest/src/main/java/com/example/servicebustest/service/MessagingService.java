package com.example.servicebustest.service;

import javax.jms.JMSException;
import javax.jms.Message;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.jms.core.MessagePostProcessor;
import org.springframework.stereotype.Service;

@Service
public class MessagingService {
    private static final String DESTINATION_NAME = "servicebusperftestjavaqueue";
    private static final Logger logger = LoggerFactory.getLogger(MessagingService.class);

    @Autowired
    private JmsTemplate jmsTemplate;

    public void postMessage(String message) {
        logger.info("MessagingService.postMessage");
        jmsTemplate.convertAndSend(DESTINATION_NAME, message, new MessagePostProcessor() {
            @Override
            public Message postProcessMessage(Message jmsMessage) throws JMSException {
                logger.info("postProcessMessage");
                return jmsMessage;
            }
        });
    }
}
