package com.itpuraan.productservice.controller

import org.springframework.beans.factory.annotation.Value
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/test")
class TestController(
    // In Kotlin, use @field:Value to specify the annotation applies to the backing field,
    // not just the constructor parameter.
    // This avoids warnings and ensures Spring injects the value correctly.
    @Value("\${test.name}") private val name: String
) {
    @GetMapping
    fun test(): String {
        return name
    }

}