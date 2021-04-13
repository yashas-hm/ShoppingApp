import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    String productId = ModalRoute.of(context).settings.arguments as String;
    final productData =
        Provider.of<Products>(context, listen: false).itemById(productId);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(productData.title),
              background: Hero(
                tag: productData.id,
                child: Image.network(
                  productData.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Text(
                  '\$${productData.price}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Text(
                    productData.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                //a little hack to show animation
                SizedBox(
                  height: 1000,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
