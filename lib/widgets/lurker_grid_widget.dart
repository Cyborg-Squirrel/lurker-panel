import 'package:flutter/material.dart';
import 'package:lurker_panel/cubits/lurker_grid_cubit.dart';
import 'package:lurker_panel/model/lurker_model.dart';
import 'package:lurker_panel/states/lurker_grid_state.dart';
import 'package:lurker_panel/widgets/window_resize_notifier_widget.dart';

import '../di/dependency_manager.dart';

class LurkerGridWidget extends StatelessWidget {
  const LurkerGridWidget({super.key});

  static const route = '/grid';

  @override
  Widget build(BuildContext context) {
    // const title = 'Lurkers';
    final cubit = getIt<LurkerGridCubit>()..onLoad();

    return Scaffold(
      // TODO idk if I want to keep this
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: const Text(title),
      // ),
      body: StreamBuilder(
        stream: cubit.stream,
        initialData: cubit.state,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data;

            final width = MediaQuery.of(context).size.width;
            final height = MediaQuery.of(context).size.height;
            final ratio = width / height;
            int crossAxisCount = 5;
            if (ratio < 5 && ratio > 1.4) {
              crossAxisCount = 5;
            } else if (ratio >= 5) {
              crossAxisCount = 8;
            } else if (ratio <= 1.4 && ratio > .5) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 1;
            }
            print('ratio $ratio');
            print('crossAxisCount $crossAxisCount');

            if (state is LurkerGridState) {
              return WindowResizeNotifierWidget(
                onWindowResizedCallback: cubit.onScreenResized,
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  children: List.generate(state.lurkerList.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          getGridItem(context, index, state.lurkerList[index]),
                    );
                  }),
                ),
              );
            }
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

void determineShape(int height, int width) {
  final ratio = width / height;

  if (ratio < 1.1 && ratio > .9) {
    print('Square');
  } else if (ratio > 1.1) {
    print('Wide');
  } else {
    print('Tall');
  }
}

Widget getGridItem(BuildContext context, int index, LurkerModel lurkerModel) {
  return GestureDetector(
    onTap: () {},
    child: Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Image.network(
              lurkerModel.profileImageUrl!,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                lurkerModel.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
