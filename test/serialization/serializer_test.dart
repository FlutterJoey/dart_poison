// ignore_for_file: Generated using data class generator
import 'dart:convert';

import 'package:test/test.dart';

import 'package:poison/poison.dart';

void main() {
  test(
    'something',
    () {
      var serializer = Serializer(viewModel: MyViewModel);

      var validator = serializer.getValidator();
      print(jsonEncode(validator.asJson()));
      try {
        validator.validate({
          'requiredInteger': 1,
          'requiredString': 'Test',
          'optionalString': 'test123',
          'nestedClass': {},
        });
      } on BadRequestException catch (e) {
        print(e.body);
      }
    },
  );
}

class MyViewModel {
  @Serialize()
  final int requiredInteger;
  @Serialize()
  final String requiredString;
  @Serialize(optional: true)
  final int? optionalInt;
  @Serialize(optional: true)
  final String? optionalString;
  @Serialize(
    serializableType: SerializableType(type: NestedClass),
  )
  final NestedClass nestedClass;

  MyViewModel({
    required this.requiredInteger,
    required this.requiredString,
    required this.nestedClass,
    this.optionalInt,
    this.optionalString,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'requiredInteger': requiredInteger,
      'requiredString': requiredString,
      'optionalInt': optionalInt,
      'optionalString': optionalString,
      'nestedClass': nestedClass.toMap(),
    };
  }

  factory MyViewModel.fromMap(Map<String, dynamic> map) {
    return MyViewModel(
      requiredInteger: map['requiredInteger'] as int,
      requiredString: map['requiredString'] as String,
      optionalInt:
          map['optionalInt'] != null ? map['optionalInt'] as int : null,
      optionalString: map['optionalString'] != null
          ? map['optionalString'] as String
          : null,
      nestedClass:
          NestedClass.fromMap(map['nestedClass'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());
}

class NestedClass {
  @Serialize(
    optional: true,
  )
  final String? name;
  @Serialize(
    optional: true,
    serializableType: SerializableType(type: Item, optional: true),
  )
  final List<Item?>? items;
  NestedClass({
    this.name,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'items': items?.map((x) => x?.toMap()).toList(),
    };
  }

  factory NestedClass.fromMap(Map<String, dynamic> map) {
    return NestedClass(
      name: map['name'] != null ? map['name'] as String : null,
      items: map['items'] != null
          ? List<Item>.from(
              (map['items'] as List<int>).map<Item?>(
                (x) => Item.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());
}

class SomeModel {
  @Serialize(optional: true)
  String a;
  @Serialize()
  String b;
  @Serialize()
  int d;
  @Serialize(validator: validate)
  double x;
  SomeModel({
    required this.a,
    required this.b,
    required this.d,
    required this.x,
  });
}

String? validate(value) => value > 0 ? 'Value needs to be above 0' : null;

class Item {
  @Serialize()
  final int? id;
  @Serialize()
  final double? price;
  Item({
    this.id,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'price': price,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] != null ? map['id'] as int : null,
      price: map['price'] != null ? map['price'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());
}

class MyNested {
  final MyNested? child;
  MyNested({
    required this.child,
  });
}

var a = MyNested(child: MyNested(child: MyNested(child: null)));
