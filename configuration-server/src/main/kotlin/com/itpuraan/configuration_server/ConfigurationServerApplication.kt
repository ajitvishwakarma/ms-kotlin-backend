package com.itpuraan.configuration_server

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.config.server.EnableConfigServer

@SpringBootApplication
@EnableConfigServer
class ConfigurationServerApplication

fun main(args: Array<String>) {
	runApplication<ConfigurationServerApplication>(*args)
}
