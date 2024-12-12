from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinLengthValidator
from django.core.validators import MaxLengthValidator
from django.contrib.auth.models import AbstractUser
import uuid
from datetime import timedelta
from django.utils.timezone import now

# Model Brands
class Brand(models.Model):
    brand_id = models.AutoField(primary_key=True)
    brand_name = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.brand_name
    
    class Meta:
        db_table = 'Brand'

# Model Categories
class Category(models.Model):
    category_id = models.AutoField(primary_key=True)
    category_name = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.category_name
    class Meta:
        db_table = 'Category'

# Model BrandCategories
class BrandCategory(models.Model):
    brand_category_id = models.AutoField(primary_key=True)
    brand = models.ForeignKey(Brand, on_delete=models.CASCADE, related_name='categories')
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='brands')

    def __str__(self):
        return f"{self.brand.brand_name} - {self.category.category_name}"
    class Meta:
        db_table = 'BrandCategory'
# Model SkinTones
class SkinTone(models.Model):

    skintone_id = models.AutoField(primary_key=True)
    skintone_name = models.CharField(max_length=20, null=True, blank=True)
    skintone_description = models.CharField(max_length=1000, null=True, blank=True)
    hex_range_start = models.CharField(max_length=7, null=True, blank=True)  # HEX mulai
    hex_range_end = models.CharField(max_length=7, null=True, blank=True)  # HEX akhir
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.skintone_name
    class Meta:
        db_table = 'SkinTone'

class Role(models.Model):
    role_id = models.AutoField(primary_key=True)
    role_name = models.CharField(max_length=20, choices=[('pengguna','Pengguna'),('admin','Admin')])
    
    def __str__(self):
        return self.role_name
    class Meta:
        db_table = 'Role'

# Model Users
class Pengguna(models.Model):
    user_id = models.AutoField(primary_key=True)
    username = models.CharField(max_length=50, unique=True)
    password = models.CharField(max_length=255, validators=[MinLengthValidator(6)])
    email = models.EmailField(max_length=100, unique=True)
    jenis_kelamin = models.CharField(max_length=100, null=True, blank=True, choices=[('pria','pria'),('wanita','wanita')])
    skintone = models.ForeignKey(SkinTone, on_delete=models.SET_NULL, null=True, blank=True, related_name='pengguna')
    profile_picture = models.ImageField(
        upload_to='profile_pictures/', null=True, blank=True
    )
    role = models.ForeignKey(Role, on_delete=models.SET_NULL, null=True, related_name='pengguna' )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_login = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    token = models.CharField(max_length=255, null=True, blank=True)
    
    def get_email_field_name(self):
        return "email"
    
    def __str__(self):
        return self.username
    class Meta:
        db_table = 'Pengguna'
# Model Products
class Product(models.Model):
    product_id = models.AutoField(primary_key=True)
    product_name = models.CharField(max_length=100)
    brand = models.CharField(max_length=255, null=True, blank=True)
    product_type = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    image_url = models.URLField(max_length=1000, null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)  # Harga dengan 2 desimal
    price_sign = models.CharField(max_length=10, null=True, blank=True)  # $, €, dll
    currency = models.CharField(max_length=10, null=True, blank=True)  # USD, IDR, dll
    product_link = models.URLField(max_length=1000, null=True, blank=True)  # Link produk
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.product_name
    class Meta:
        db_table = 'Product'

class ProductColor(models.Model):
    color_id = models.AutoField(primary_key=True)
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name = 'colors')
    hex_value = models.CharField(max_length=7)
    color_name = models.CharField(max_length=255, null=True, blank=True)
    
    def __str__(self):
        return f"{self.product.product_name} - {self.color_name}"
    
    class Meta:
        db_table = 'ProductColor'
        
class Recommendation(models.Model):
    recommendation_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(Pengguna, on_delete=models.CASCADE, related_name='makeup_recommendations')
    skintone = models.ForeignKey(SkinTone, on_delete=models.CASCADE, related_name='makeup_recommendations')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='makeup_recommendations')
    color = models.ForeignKey(ProductColor, on_delete=models.CASCADE, related_name='recommendation_colors')
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Recommendation for {self.user.username} - {self.product.product_name}"
    class Meta:
        db_table = 'Recommendation'