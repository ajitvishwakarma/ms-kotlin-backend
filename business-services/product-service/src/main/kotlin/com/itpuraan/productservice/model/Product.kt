package com.itpuraan.productservice.model

import org.springframework.data.annotation.Id
import java.math.BigDecimal

data class Product(
    @Id
    val id: String? = null, // id is nullable and defaults to null for auto-generation
    val name: String,
    val description: String,
    val price: BigDecimal
)
