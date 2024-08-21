import 'package:equatable/equatable.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';

class OnBoardingData extends Equatable {
  final String image;
  final String title;
  final String subTitle;

  const OnBoardingData({
    required this.image,
    required this.title,
    required this.subTitle,
  });

  @override
  List<Object?> get props => [
        image,
        title,
        subTitle,
      ];
}

final List<OnBoardingData> data = [
  const OnBoardingData(
    image: KImages.onBoarding01,
    title: 'Welcome to the Service EZPC TASKS!',
    subTitle:
        'Curates the best new blockchain jobs at leading companies that use blockchain technology',
  ),
  const OnBoardingData(
    image: KImages.onBoarding02,
    title: 'EZPC TASKS your on boarding Awaits!',
    subTitle:
        'EZPC Curates the best new blockchain jobs at leading companies that use blockchain technology',
  ),
  // const OnBoardingData(
  //   image: KImages.onBoarding01,
  //   title: 'Welcome to the Service Seller Revolution!',
  //   subTitle:
  //       'Curates the best new blockchain jobs at leading companies that use blockchain technology',
  // ),
  // const OnBoardingData(
  //   image: KImages.onBoarding02,
  //   title: 'Sell Services your on boarding Awaits!',
  //   subTitle:
  //       'Curates the best new blockchain jobs at leading companies that use blockchain technology',
  // ),
];
