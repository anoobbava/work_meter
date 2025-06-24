import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function refreshLogData;
  MyAppBar(this.refreshLogData);
  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        // backgroundColor: Colors.green,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        actions: <Widget>[
          // Dark mode toggle
          Consumer<AppState>(
            builder: (context, appState, child) {
              return IconButton(
                color: Theme.of(context).colorScheme.secondary,
                icon: Icon(
                  appState.isDarkModeOn ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: appState.isDarkModeOn ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  appState.updateTheme(!appState.isDarkModeOn);
                },
              );
            },
          ),
          // Refresh button
          IconButton(
              color: Theme.of(context).colorScheme.secondary,
              icon: Icon(Icons.refresh),
              alignment: Alignment.topCenter,
              tooltip: 'Refresh the Data',
              onPressed: () => refreshLogData())
        ],
        title: Center(
          child: Text(
            ' Work meter',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                fontFamily: 'openSans'),
          ),
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
