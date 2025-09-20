import com.itpuraan.productservice.controller.ProductController
import com.itpuraan.productservice.model.Product
import com.itpuraan.productservice.service.ProductService
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.math.BigDecimal

@ExtendWith(MockitoExtension::class)
class ProductControllerTest {

    @Mock
    lateinit var productsService: ProductService

    @InjectMocks
    lateinit var productsController: ProductController

    @Test
    fun `should return product by id`() {
        val product1 = Product(
            id = "1",
            name = "Test Product",
            description = "Test Description",
            price = BigDecimal.valueOf(1002L)
        )

        val product2 = product1.copy(id = "2")

        `when`(productsService.getAllProducts())
            .thenReturn(listOf(product1, product2))

        val result = productsController.getProducts()

        assertEquals(listOf(product1, product2), result)
    }
}
