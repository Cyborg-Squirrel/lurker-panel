import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lurker_panel/cubits/lurker_grid_cubit.dart';
import 'package:lurker_panel/model/lurker_model.dart';
import 'package:lurker_panel/states/lurker_grid_state.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: StreamBuilder(
          stream: cubit.stream,
          initialData: cubit.state,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final state = snapshot.data;

              final width = MediaQuery.of(context).size.width;
              final height = MediaQuery.of(context).size.height;
              final ratio = width / height;
              int crossAxisCount = 5;
              if (ratio > 6) {
                crossAxisCount = 8;
              } else if (ratio > 1.4) {
                crossAxisCount = 5;
              } else if (ratio > 1 && ratio <= 1.4) {
                crossAxisCount = 3;
              } else if (ratio > .5 && ratio < 1) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 1;
              }
              print('ratio $ratio');
              print('crossAxisCount $crossAxisCount');

              if (state is LurkerGridState) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    children: List.generate(state.lurkerList.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: getGridItem(
                            context, index, state.lurkerList[index]),
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
      ),
    );
  }
}

Widget getGridItem(BuildContext context, int index, LurkerModel lurkerModel) {
  var displayName = lurkerModel.name;
  if (displayName.length > 13) {
    displayName = '${displayName.substring(0, 10)}...';
  }
  return GestureDetector(
    onTap: () {
      getIt<LurkerGridCubit>().unlurk(lurkerModel);
    },
    child: Card(
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Center(
              child: CircleAvatar(
                radius: 300,
                backgroundImage: NetworkImage(lurkerModel.profileImageUrl!),
              ),
            ),
          ),
          Center(
            child: Container(
                padding: const EdgeInsets.all(4.0),
                child: Stack(
                  children: <Widget>[
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 24,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = Colors.black,
                      ),
                    ),
                    // Solid text as fill.
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    ),
  );
}
