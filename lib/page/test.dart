import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Beer {
  final String? name;
  final String? category;
  final String? image;

  final double? averageRating;
  final int? reviews;

  Beer({
    required this.name,
    required this.category,
    required this.image,
    this.averageRating,
    this.reviews,
  });

  factory Beer.fromJson(Map<String, dynamic> json) {
    return Beer(
      name: json['name'],
      category: json['category'],
      image: json['image'],
      //price: json['price'] != null ? double.parse(json['price']) : null,
      averageRating: json['rating'] != null ? json['rating']['average'] : null,
      reviews: json['rating'] != null ? json['rating']['reviews'] : null,
    );
  }
}


class YourWidget extends StatefulWidget {
  const YourWidget({Key? key}) : super(key: key);

  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  List<Beer>? _beers;

  // เมธอดสำหรับโหลดข้อมูล
  void _getBeers() async {
    try {
      var dio = Dio(BaseOptions(responseType: ResponseType.plain));
      var response = await dio.get('https://api.sampleapis.com/beers/ale');
      List list = jsonDecode(response.data);

      setState(() {
        _beers = list.map((beer) => Beer.fromJson(beer)).toList();

        // เรียงลำดับตามชื่อจาก A ไป Z (กรณีต้องการเรียงลำดับ)
        _beers!.sort((a, b) => a.name!.compareTo(b.name!));
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // เรียกเมธอดสำหรับโหลดข้อมูลใน initState() ของคลาสที่ extends มาจาก State
    _getBeers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beer List'),
      ),
      body: _beers == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _beers!.length,
              itemBuilder: (context, index) {
                var beer = _beers![index];

                return ListTile(
                  title: Text(beer.name ?? ''),
                  subtitle: Text(beer.category ?? ''),
                  trailing: beer.image != null
                      ? Image.network(
                          beer.image!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : SizedBox
                          .shrink(), // ป้องกันการแสดงรูปภาพเมื่อ URL ไม่มีค่า
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(beer.name ?? ''),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('review: ${beer.reviews != null ? beer.reviews.toString() : 'N/A'}'),
                              Text('Average Rate: ${beer.averageRating != null ? beer.averageRating.toString() : 'N/A'}'),
                              Text('Category: ${beer.category ?? ''}'),
                              beer.image != null
                                  ? Image.network(
                                      beer.image!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
