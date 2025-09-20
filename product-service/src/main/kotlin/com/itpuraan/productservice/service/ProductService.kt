package com.itpuraan.productservice.service

import com.itpuraan.productservice.model.Product
import com.itpuraan.productservice.repository.ProductRepository
import org.springframework.stereotype.Service

@Service
class ProductService(
    val productRepository: ProductRepository
) {

    fun getAllProducts(): List<Product> {
        return productRepository.findAll()
    }

    fun saveProduct(product: Product) {
        productRepository.save(product)
    }

}