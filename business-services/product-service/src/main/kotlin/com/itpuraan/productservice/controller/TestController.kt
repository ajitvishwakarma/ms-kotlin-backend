package com.itpuraan.productservice.controller

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.cloud.context.config.annotation.RefreshScope
import org.springframework.stereotype.Component
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Component
@ConfigurationProperties(prefix = "test")
@RefreshScope
data class TestProperties(
    var name: String = "default"
)

@RestController
@RequestMapping("/api/test")
@EnableConfigurationProperties(TestProperties::class)
class TestController(@Autowired private val testProperties: TestProperties) {

    @GetMapping
    fun test(): String {
        return "Current value: ${testProperties.name}"
    }
}