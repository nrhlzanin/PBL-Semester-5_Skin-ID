import 'package:flutter/material.dart';

class FilterableProductList extends StatefulWidget {
  @override
  _FilterableProductListState createState() => _FilterableProductListState();
}

class _FilterableProductListState extends State<FilterableProductList> {
  String selectedCategory = 'All'; // Kategori yang dipilih
  final List<Map<String, String>> products = [
    {'name': 'Lipstick A', 'category': 'Lipstick'},
    {'name': 'Lipstick B', 'category': 'Lipstick'},
    {'name': 'Eyeliner A', 'category': 'Eyeliner'},
    {'name': 'Mascara A', 'category': 'Mascara'},
    {'name': 'Mascara B', 'category': 'Mascara'},
  ];

  @override
  Widget build(BuildContext context) {
    // Filter produk berdasarkan kategori yang dipilih
    final filteredProducts = selectedCategory == 'All'
        ? products
        : products.where((product) => product['category'] == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Filter Products')),
      body: Column(
        children: [
          // Filter Buttons
          Row(
            children: [
              FilterButton(
                label: 'All',
                isSelected: selectedCategory == 'All',
                onTap: () => setState(() => selectedCategory = 'All'),
              ),
              SizedBox(width: 8.0),
              FilterButton(
                label: 'Lipstick',
                isSelected: selectedCategory == 'Lipstick',
                onTap: () => setState(() => selectedCategory = 'Lipstick'),
              ),
              SizedBox(width: 8.0),
              FilterButton(
                label: 'Eyeliner',
                isSelected: selectedCategory == 'Eyeliner',
                onTap: () => setState(() => selectedCategory = 'Eyeliner'),
              ),
              SizedBox(width: 8.0),
              FilterButton(
                label: 'Mascara',
                isSelected: selectedCategory == 'Mascara',
                onTap: () => setState(() => selectedCategory = 'Mascara'),
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // List Produk
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(product['name']!),
                  subtitle: Text(product['category']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
