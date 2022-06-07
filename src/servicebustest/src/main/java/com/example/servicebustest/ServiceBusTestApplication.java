package com.example.servicebustest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ServiceBusTestApplication implements CommandLineRunner {
	private static final Logger logger = LoggerFactory.getLogger(ServiceBusTestApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(ServiceBusTestApplication.class, args);
	}

	@Override
	public void run(String... args) {
		logger.info("Start");
	}
}
