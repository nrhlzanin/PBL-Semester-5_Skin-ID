from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinLengthValidator
from django.core.validators import MaxLengthValidator
from django.contrib.auth.models import AbstractUser
import uuid

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
    skintone_description = models.CharField(max_length=255, null=True, blank=True)
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
    skintone = models.ForeignKey(SkinTone, on_delete=models.SET_NULL, null=True, blank=True, related_name='pengguna')
    role_id = models.ForeignKey(Role, on_delete=models.SET_NULL, null=True, related_name='pengguna' )
    is_verified = models.BooleanField(default=False)
    verification_token = models.UUIDField(default=None, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_login = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    def get_email_field_name(self):
        return "email"
    
    def __str__(self):
        return self.username
    class Meta:
        db_table = 'Pengguna'

# class Pengguna(AbstractUser):
#     skintone = models.ForeignKey(SkinTone, on_delete=models.SET_NULL, null=True, blank=True, related_name='pengguna')
#     role_id = models.ForeignKey(Role, on_delete=models.SET_NULL, null=True, related_name='pengguna')
#     is_verified = models.BooleanField(default=False)
#     verification_token = models.UUIDField(default=None, null=True)

#     class Meta:
#         db_table = 'Pengguna'
        
# Model Products
class Product(models.Model):
    product_id = models.AutoField(primary_key=True)
    product_name = models.CharField(max_length=100)
    brand_category = models.ForeignKey(BrandCategory, on_delete=models.SET_NULL, null=True, blank=True, related_name='products')
    description = models.TextField(null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image_url = models.URLField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.product_name
    class Meta:
        db_table = 'Product'

# Model Recommendations
class Recommendation(models.Model):
    recommendation_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='recommendations')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='recommendations')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Recommendation for {self.user.username} - {self.product.product_name}"
    class Meta:
        db_table = 'Recommendation'
