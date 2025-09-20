package com.itpuraan.productservice.repository

import com.itpuraan.productservice.model.Product
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository

@Repository
interface ProductRepository : MongoRepository<Product, String> {
}