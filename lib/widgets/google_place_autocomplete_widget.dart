import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

class GooglePlaceAutoCompleteWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(Prediction) onPlaceSelected;

  const GooglePlaceAutoCompleteWidget({
    Key? key,
    required this.label,
    required this.controller,
    required this.onPlaceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 21),
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xFFEBEBEB),
          ),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: controller,
            googleAPIKey: "AIzaSyBjDL2P5Nd50J6KR0qqi6PlrAmsS0MBa7c",
            inputDecoration: InputDecoration(
              border: InputBorder.none, // Match `CustomTextBox`
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
            debounceTime: 800,
            countries: ["lk"],
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              print("Place details: ${prediction.lng}, ${prediction.lat}");
            },
            itemClick: (Prediction prediction) {
              controller.text = prediction.description ?? "";
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));
              onPlaceSelected(prediction);
            },
            itemBuilder: (context, index, Prediction prediction) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 7),
                    Expanded(child: Text("${prediction.description ?? ""}")),
                  ],
                ),
              );
            },
            seperatedBuilder: Divider(),
            isCrossBtnShown: true,
            containerHorizontalPadding: 10,
            placeType: PlaceType.geocode,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
