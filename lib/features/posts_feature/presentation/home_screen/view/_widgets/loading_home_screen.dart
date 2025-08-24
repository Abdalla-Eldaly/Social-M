import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreenLoading extends StatelessWidget {
  const HomeScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Skeletonizer(
          enabled: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Skeleton.leaf(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Skeleton.leaf(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
        
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Skeleton.leaf(
                                    child: Container(
                                      width: 100,
                                      height: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Skeleton.leaf(
                                    child: Container(
                                      width: 80,
                                      height: 12,
                                      decoration: BoxDecoration(
                                          color: Colors.grey,
                                        borderRadius: BorderRadius.circular(12)
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Skeleton.replace(
                            width: double.infinity,
                            height: 200,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Skeleton.leaf(
                                child: Container(
                                  width: 50,
                                  height: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Skeleton.leaf(
                                child: Container(
                                  width: 50,
                                  height: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Skeleton.leaf(
                                child: Container(
                                  width: 50,
                                  height: 16,
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
        
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Skeleton.leaf(
                            child: Container(
                              width: double.infinity,
                              height: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}