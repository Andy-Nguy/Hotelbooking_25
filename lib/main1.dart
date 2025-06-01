// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Demo',
// //       theme: ThemeData(
// //         // This is the theme of your application.
// //         //
// //         // TRY THIS: Try running your application with "flutter run". You'll see
// //         // the application has a purple toolbar. Then, without quitting the app,
// //         // try changing the seedColor in the colorScheme below to Colors.green
// //         // and then invoke "hot reload" (save your changes or press the "hot
// //         // reload" button in a Flutter-supported IDE, or press "r" if you used
// //         // the command line to start the app).
// //         //
// //         // Notice that the counter didn't reset back to zero; the application
// //         // state is not lost during the reload. To reset the state, use hot
// //         // restart instead.
// //         //
// //         // This works for code too, not just values: Most code changes can be
// //         // tested with just a hot reload.
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //       ),
// //       home: const MyHomePage(title: 'Flutter Demo Home Page'),
// //     );
// //   }
// // }

// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({super.key, required this.title});

// //   // This widget is the home page of your application. It is stateful, meaning
// //   // that it has a State object (defined below) that contains fields that affect
// //   // how it looks.

// //   // This class is the configuration for the state. It holds the values (in this
// //   // case the title) provided by the parent (in this case the App widget) and
// //   // used by the build method of the State. Fields in a Widget subclass are
// //   // always marked "final".

// //   final String title;

// //   @override
// //   State<MyHomePage> createState() => _MyHomePageState();
// // }

// // class _MyHomePageState extends State<MyHomePage> {
// //   int _counter = 0;

// //   void _incrementCounter() {
// //     setState(() {
// //       // This call to setState tells the Flutter framework that something has
// //       // changed in this State, which causes it to rerun the build method below
// //       // so that the display can reflect the updated values. If we changed
// //       // _counter without calling setState(), then the build method would not be
// //       // called again, and so nothing would appear to happen.
// //       _counter++;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // This method is rerun every time setState is called, for instance as done
// //     // by the _incrementCounter method above.
// //     //
// //     // The Flutter framework has been optimized to make rerunning build methods
// //     // fast, so that you can just rebuild anything that needs updating rather
// //     // than having to individually change instances of widgets.
// //     return Scaffold(
// //       appBar: AppBar(
// //         // TRY THIS: Try changing the color here to a specific color (to
// //         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
// //         // change color while the other colors stay the same.
// //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
// //         // Here we take the value from the MyHomePage object that was created by
// //         // the App.build method, and use it to set our appbar title.
// //         title: Text(widget.title),
// //       ),
// //       body: Center(
// //         // Center is a layout widget. It takes a single child and positions it
// //         // in the middle of the parent.
// //         child: Column(
// //           // Column is also a layout widget. It takes a list of children and
// //           // arranges them vertically. By default, it sizes itself to fit its
// //           // children horizontally, and tries to be as tall as its parent.
// //           //
// //           // Column has various properties to control how it sizes itself and
// //           // how it positions its children. Here we use mainAxisAlignment to
// //           // center the children vertically; the main axis here is the vertical
// //           // axis because Columns are vertical (the cross axis would be
// //           // horizontal).
// //           //
// //           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
// //           // action in the IDE, or press "p" in the console), to see the
// //           // wireframe for each widget.
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             const Text('You have pushed the button this many times:'),
// //             Text(
// //               '$_counter',
// //               style: Theme.of(context).textTheme.headlineMedium,
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: _incrementCounter,
// //         tooltip: 'Increment',
// //         child: const Icon(Icons.add),
// //       ), // This trailing comma makes auto-formatting nicer for build methods.
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Marriott Bonvoy Mobile',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const HomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Marriott Bonvoy Mobile',
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //       home:
// //           const HomePage(), // HomePage vẫn có thể là const nếu nội dung bên trong không đổi
// //     );
// //   }
// // }

// class BenefitItem extends StatelessWidget {
//   final IconData icon;
//   final String text;

//   const BenefitItem({super.key, required this.icon, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Container(
//           padding: const EdgeInsets.all(15.0),
//           decoration: BoxDecoration(
//             border: Border(
//               right:
//                   constraints.maxWidth < double.infinity
//                       ? const BorderSide(width: 0.5, color: Colors.grey)
//                       : BorderSide.none,
//               bottom: const BorderSide(width: 0.5, color: Colors.grey),
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 25.0,
//                 color: Colors.grey[600], // Tương ứng với #676767
//               ),
//               const SizedBox(height: 10.0),
//               Text(
//                 text,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 16.0,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                   height: 1.4,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final PageController _pageController = PageController(viewportFraction: 0.8);
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController.addListener(() {
//       setState(() {
//         _currentPage = _pageController.page?.round() ?? 0;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // icon:
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: null,
//       //header-section
//       body: SingleChildScrollView(
//         // Loại bỏ const ở đây
//         child: Column(
//           // Loại bỏ const ở đây
//           children: [
//             // Header
//             Container(
//               // Loại bỏ const ở đây
//               padding: const EdgeInsets.all(8.0), // Thêm const vào EdgeInsets
//               decoration: const BoxDecoration(
//                 // Thêm const vào BoxDecoration
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     offset: Offset(0, 2),
//                     blurRadius: 5.0,
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment:
//                     CrossAxisAlignment.center, // Sửa thành crossAxisAlignment
//                 children: [
//                   // Menu Icon
//                   const Padding(
//                     // Thêm const vào Padding
//                     padding: EdgeInsets.only(left: 10.0),
//                     child: Text(
//                       '☰',
//                       style: TextStyle(fontSize: 24.0, color: Colors.black87),
//                     ),
//                   ),
//                   // Logo
//                   Padding(
//                     // Loại bỏ const vì Image.asset không phải là const
//                     padding: const EdgeInsets.only(left: 10.0),
//                     child: Image.asset(
//                       'assets/image/logo.jpg',
//                       height: 55,
//                       width: 150,
//                     ),
//                   ),
//                   // Login Icon
//                   const Padding(
//                     // Thêm const vào Padding
//                     padding: EdgeInsets.only(right: 10.0),
//                     child: Icon(
//                       Icons.person_outline,
//                       size: 20.0,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             //Hero-Section
//             // Hero Section
//             Stack(
//               children: [
//                 // Background Image
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 6.0),
//                   constraints: const BoxConstraints(minHeight: 500),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.0),
//                     image: const DecorationImage(
//                       image: AssetImage(
//                         'assets/image/hcm.jpg',
//                       ), // Đảm bảo có ảnh này
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 // Overlay
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8.0),
//                       color: Colors.black.withOpacity(
//                         0.3,
//                       ), // Màu đen với độ trong suốt 30%
//                     ),
//                   ),
//                 ),
//                 // Content (Check-in/Check-out và Promotion)
//                 Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Check-in/Check-out
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.9), // Nền trắng mờ
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 15.0,
//                           vertical: 10.0,
//                         ),
//                         margin: const EdgeInsets.only(bottom: 20.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             // Check-in
//                             Expanded(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on, // Icon địa điểm
//                                     color: Color(0xFFFF5A5F),
//                                     size: 16.0,
//                                   ),
//                                   const SizedBox(width: 8.0),
//                                   Flexible(
//                                     child: const Text(
//                                       'Điểm đến tiếp theo',
//                                       style: TextStyle(
//                                         fontSize: 14.0,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                   // const Text(
//                                   //   'Điểm đến tiếp theo',
//                                   //   style: TextStyle(
//                                   //     fontSize: 14.0,
//                                   //     color: Colors.black87,
//                                   //   ),
//                                   // ),
//                                 ],
//                               ),
//                             ),
//                             // Divider
//                             Container(
//                               width: 1.0,
//                               height: 20.0,
//                               color: Colors.black54,
//                               margin: const EdgeInsets.symmetric(
//                                 horizontal: 10.0,
//                               ),
//                             ),
//                             // Check-out
//                             Expanded(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(
//                                     Icons.calendar_today, // Icon lịch
//                                     color: Colors.blue,
//                                     size: 16.0,
//                                   ),
//                                   const SizedBox(width: 8.0),
//                                   const Text(
//                                     'Thêm ngày',
//                                     style: TextStyle(
//                                       fontSize: 14.0,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Promotion
//                       Container(
//                         padding: const EdgeInsets.all(15.0),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(
//                             8.0,
//                           ), // Để có thể áp dụng padding mà không bị tràn ra ngoài overlay
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Ưu đãi giới hạn',
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 shadows: [
//                                   Shadow(
//                                     offset: Offset(1.0, 1.0),
//                                     blurRadius: 2.0,
//                                     color: Colors.black54,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 5.0),
//                             const Text(
//                               'Khám phá & Tiết kiệm tại Hồ Chí Minh',
//                               style: TextStyle(
//                                 fontSize: 24.0,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 height: 1.2,
//                                 shadows: [
//                                   Shadow(
//                                     offset: Offset(1.0, 1.0),
//                                     blurRadius: 2.0,
//                                     color: Colors.black54,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 15.0),
//                             const Text(
//                               'Tận hưởng ưu đãi đặc biệt cho kỳ nghỉ của bạn.',
//                               style: TextStyle(
//                                 fontSize: 14.0,
//                                 color: Colors.white,
//                                 height: 1.5,
//                                 shadows: [
//                                   Shadow(
//                                     offset: Offset(1.0, 1.0),
//                                     blurRadius: 2.0,
//                                     color: Colors.black54,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 15.0),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   // Xử lý sự kiện đặt ngay
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                   foregroundColor: Colors.black,
//                                   padding: const EdgeInsets.all(10.0),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(5.0),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'Đặt ngay',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             // Carousel Section 1
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Ưu đãi nổi bật',
//                     style: TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 5.0),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Flexible(
//                         child: const Text(
//                           'Khám phá các ưu đãi đặc biệt dành riêng cho bạn.',
//                           style: TextStyle(
//                             fontSize: 15.0,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       ),
//                       // const Text(
//                       //   'Khám phá các ưu đãi đặc biệt dành riêng cho bạn.',
//                       //   style: TextStyle(fontSize: 15.0, color: Colors.black54),
//                       // ),
//                       // TextButton(
//                       //   onPressed: () {
//                       //     // Xử lý xem tất cả
//                       //   },
//                       //   style: TextButton.styleFrom(
//                       //     foregroundColor: Colors.black87,
//                       //   ),
//                       //   child: const Row(
//                       //     children: [
//                       //       Text(
//                       //         'Xem tất cả',
//                       //         style: TextStyle(fontSize: 13.0),
//                       //       ),
//                       //       Icon(Icons.arrow_forward_ios, size: 16.0),
//                       //     ],
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                   const SizedBox(height: 15.0),
//                   SizedBox(
//                     height: 350.0, // Chiều cao ước tính của mỗi slide
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: 3, // Số lượng slide (ví dụ)
//                       itemBuilder: (context, index) {
//                         return Container(
//                           width: 300.0, // Chiều rộng ước tính của mỗi slide
//                           margin: const EdgeInsets.only(right: 10.0),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8.0),
//                             boxShadow: const [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 offset: Offset(0, 2),
//                                 blurRadius: 5.0,
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: ClipRRect(
//                                   borderRadius: const BorderRadius.vertical(
//                                     top: Radius.circular(8.0),
//                                   ),
//                                   child: Image.asset(
//                                     // 'assets/image/1_$index.png', // Thay bằng đường dẫn ảnh thật
//                                     'assets/image/1.png',
//                                     fit: BoxFit.contain,
//                                     width: double.infinity,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return const SizedBox(
//                                         height: 350,
//                                         child: Center(
//                                           child: Text('Không thể tải ảnh'),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(10.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Ưu đãi đặc biệt $index',
//                                       style: const TextStyle(
//                                         fontSize: 16.0,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 5.0),
//                                     const Text(
//                                       'Mô tả ngắn về ưu đãi.',
//                                       style: TextStyle(
//                                         fontSize: 14.0,
//                                         color: Colors.black54,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10.0),
//                                     Align(
//                                       alignment: Alignment.bottomRight,
//                                       child: Icon(
//                                         Icons.arrow_forward,
//                                         color: Colors.black54,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Carousel Section 2
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10.0),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Khám phá các điểm đến',
//                     style: TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 10.0),
//                   SizedBox(
//                     height: 200.0,
//                     child: Stack(
//                       children: [
//                         PageView.builder(
//                           controller: _pageController,
//                           itemCount: 3, // Số lượng slide
//                           itemBuilder: (context, index) {
//                             return AnimatedScale(
//                               duration: const Duration(milliseconds: 300),
//                               scale: _currentPage == index ? 1.0 : 0.9,
//                               child: Container(
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 10.0,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   image: DecorationImage(
//                                     image: AssetImage(
//                                       // 'assets/image/3_$index.png',
//                                       'assets/image/hotel_$index.jpg',
//                                     ), // Thay bằng đường dẫn ảnh thật
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         Positioned(
//                           left: 10.0,
//                           top: 0,
//                           bottom: 0,
//                           child: Center(
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.arrow_back_ios,
//                                 color: Colors.black54,
//                               ),
//                               onPressed: () {
//                                 _pageController.previousPage(
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeInOut,
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           right: 10.0,
//                           top: 0,
//                           bottom: 0,
//                           child: Center(
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.arrow_forward_ios,
//                                 color: Colors.black54,
//                               ),
//                               onPressed: () {
//                                 _pageController.nextPage(
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeInOut,
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 10.0,
//                           left: 0,
//                           right: 0,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(
//                               3,
//                               (index) => Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 5.0,
//                                 ),
//                                 child: AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   width: _currentPage == index ? 12.0 : 8.0,
//                                   height: _currentPage == index ? 12.0 : 8.0,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color:
//                                         _currentPage == index
//                                             ? Colors.black87
//                                             : Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Benefits Section
//             Container(
//               padding: const EdgeInsets.all(20.0),
//               margin: const EdgeInsets.symmetric(
//                 horizontal: 20.0,
//                 vertical: 10.0,
//               ), // Thêm margin cho đẹp
//               decoration: BoxDecoration(
//                 color: Colors.grey[200], // Tương ứng với #f5f5f5
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Tại sao nên chọn Marriott Bonvoy?',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 24.0,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 10.0),
//                   const Text(
//                     'Tận hưởng những lợi ích độc quyền khi bạn là thành viên của chúng tôi.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14.0,
//                       color: Colors.black54,
//                       // lineHeight: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 20.0),
//                   GridView.count(
//                     shrinkWrap: true,
//                     physics:
//                         const NeverScrollableScrollPhysics(), // Ngăn cuộn bên trong GridView
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 0,
//                     mainAxisSpacing: 0,
//                     children: const [
//                       BenefitItem(
//                         icon: Icons.hotel,
//                         text: 'Ưu đãi lưu trú tốt nhất',
//                       ),
//                       BenefitItem(
//                         icon: Icons.restaurant,
//                         text: 'Giảm giá ẩm thực',
//                       ),
//                       BenefitItem(
//                         icon: Icons.spa,
//                         text: 'Ưu đãi spa & thư giãn',
//                       ),
//                       BenefitItem(icon: Icons.wifi, text: 'Wi-Fi miễn phí'),
//                     ],
//                   ),
//                   const SizedBox(height: 15.0),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Xử lý tham gia miễn phí
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Colors.black87, // Tương ứng với màu secondary
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.all(12.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                         ),
//                       ),
//                       child: const Text(
//                         'Tham gia miễn phí',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10.0),
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton(
//                       onPressed: () {
//                         // Xử lý đăng nhập
//                       },
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor:
//                             Colors.black87, // Tương ứng với màu outline
//                         padding: const EdgeInsets.all(12.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                         ),
//                         side: const BorderSide(
//                           color: Colors.black87,
//                         ), // Viền đen
//                       ),
//                       child: const Text(
//                         'Đăng nhập',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Các section khác sẽ được thêm vào đây
//           ],
//         ),
//       ),
//     );
//   }
// }
