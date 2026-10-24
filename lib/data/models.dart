class Camera {
  const Camera(this.name, this.address, this.distance, this.minutes);
  final String name, address, distance;
  final int minutes;
}

const cameras = [
  Camera('Canon 750D', '10 Bilpar Road, Lamabazar, Sylhet', '3 km', 4),
  Camera('Nikon 1200D', 'Amla Camera, Zindabazar, Sylhet', '1.2 km', 3),
  Camera('Sony HX6', 'Hafiz Tower, Mirabazar, Sylhet', '2.4 km', 5),
];

class Rental {
  const Rental(this.camera, this.address, this.time, this.cents);
  final String camera, address, time;
  final int cents;
  Map<String, Object> toJson() => {
    'camera': camera,
    'address': address,
    'time': time,
    'cents': cents,
  };
  factory Rental.fromJson(Map<String, dynamic> json) => Rental(
    json['camera'] as String,
    json['address'] as String,
    json['time'] as String,
    json['cents'] as int,
  );
}

const sampleRentals = [
  Rental(
    'Nikon 1200D',
    'Amla Camera, Zindabazar, Sylhet',
    '1:20 PM - 5:40 PM | 4 hr 20 min',
    410,
  ),
  Rental(
    'Sony HX6',
    'Hafiz Tower, Mirabazar, Sylhet',
    '3:10 PM - 4:15 PM | 1 hr 05 min',
    803,
  ),
  Rental(
    'Canon 5D Mark 2',
    'Tanis Tower, Zindabazar, Sylhet',
    '6:45 PM - 9:20 PM | 2 hr 35 min',
    1015,
  ),
  Rental(
    'Canon 700D',
    'Amla Camera, Zindabazar, Sylhet',
    '1:20 PM - 5:40 PM | 4 hr 20 min',
    2800,
  ),
];

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
