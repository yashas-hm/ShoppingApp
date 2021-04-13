import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterOptions {
  All,
  Favourites,
}

class ProductOverview extends StatefulWidget {

  static const routeName = '/product-overview-screen';

  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  var _isInit = true;
  var _isLoaded = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoaded = true;
      });
      Provider.of<Products>(context).fetchAndSync().catchError((error){
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Something went wrong'),
                actions: [
                  TextButton(
                    child: Text('okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              );
            });
      }).then((_) {
        setState(() {
          _isLoaded = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop App'),
        actions: <Widget>[
          Consumer<Products>(
            builder: (context, products, _) => PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (FilterOptions selectedValue) {
                if (FilterOptions.Favourites == selectedValue) {
                  products.showFav(true);
                } else {
                  products.showFav(false);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('All Products'),
                  value: FilterOptions.All,
                ),
                PopupMenuItem(
                  child: Text('Only Favourites'),
                  value: FilterOptions.Favourites,
                ),
              ],
            ),
          ),
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              child: child,
              value: cart.total.toString(),
              color: Colors.white,
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoaded
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(),
    );
  }
}
