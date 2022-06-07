package com.example.servicebustest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.env.Environment;

import com.example.servicebustest.service.MessagingService;

@SpringBootApplication
public class ServiceBusTestApplication implements CommandLineRunner {
	private static final Logger logger = LoggerFactory.getLogger(ServiceBusTestApplication.class);
	@Autowired
	private Environment env;
	@Autowired
	private MessagingService messagingService;

	public static void main(String[] args) {
		SpringApplication.run(ServiceBusTestApplication.class, args);
	}

	@Override
	public void run(String... args) {
		logger.info("Start");

		int interval = env.getProperty("INTERVAL", Integer.class, 1000);

		try {
			do {
				messagingService.postMessage("HelloWorld");
				Thread.sleep(interval);
			} while (true);
		} catch (InterruptedException ex) {
			logger.info("exit");
		}
	}
}
