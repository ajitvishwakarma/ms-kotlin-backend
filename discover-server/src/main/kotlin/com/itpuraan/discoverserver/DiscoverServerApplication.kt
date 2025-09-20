package com.itpuraan.discoverserver

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer

@SpringBootApplication
@EnableEurekaServer
class DiscoverServerApplication

fun main(args: Array<String>) {
    runApplication<DiscoverServerApplication>(*args)
}
