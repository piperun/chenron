import "package:chenron/responsible_design/breakpoints.dart";
import "package:flutter/material.dart";
import "package:chenron/responsible_design/responsive_builder.dart";

class ResponsiveExample extends StatelessWidget {
  const ResponsiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        // Example: Responsive grid columns
        int gridColumns = responsiveValue(
          context: context,
          xs: 2,
          sm: 3,
          md: 4,
          lg: 5,
          xl: 6,
        );

        // Example: Responsive background color
        Color backgroundColor = responsiveValue(
          context: context,
          xs: Colors.red,
          sm: Colors.orange,
          md: Colors.yellow,
          lg: Colors.green,
          xl: Colors.blue,
        );

        return Container(
          color: backgroundColor,
          width: Breakpoints.responsiveWidth(context),
          height: Breakpoints.responsiveHeight(context),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns,
            ),
            itemBuilder: (context, index) {
              return Card(
                child: Center(child: Text("Item $index")),
              );
            },
            itemCount: 20,
          ),
        );
      },
    );
  }
}
