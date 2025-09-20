package com.itpuraan.productservice.controller

import com.itpuraan.productservice.model.Product
import com.itpuraan.productservice.service.ProductService
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/product")
class ProductController(
    val productService: ProductService
) {

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    fun getProducts(): List<Product> {
        return productService.getAllProducts()
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun save(@RequestBody product: Product) {
        productService.saveProduct(product)
    }

}