import 'dart:mirrors';

import 'package:poison/poison.dart';

class Serializer {
  Serializer({
    required this.viewModel,
  });
  final Type viewModel;

  Map<String, ValueValidator> getValidator() {
    var classReflection = reflectClass(viewModel);
    var reflectedProperties = classReflection.declarations;

    final validatorMap = <String, ValueValidator>{};

    for (var entry in reflectedProperties.entries) {
      var mirror = entry.value;
      if (mirror is VariableMirror) {
        var annotations = mirror.metadata;
        var serializeInstance = annotations
            .whereType<InstanceMirror>()
            .where((element) => element.hasReflectee)
            .map((element) => element.reflectee)
            .whereType<Serialize>()
            .firstOrNull;

        if (serializeInstance != null) {
          var name = MirrorSystem.getName(mirror.simpleName);
          var returnType = mirror.type;
          validatorMap[name] = switch (returnType.simpleName) {
            #int => ValueValidator.int(
                optional: serializeInstance.optional,
                validator: serializeInstance.validator,
              ),
            #double => ValueValidator.double(
                optional: serializeInstance.optional,
                validator: serializeInstance.validator,
              ),
            #String => ValueValidator.string(
                optional: serializeInstance.optional,
                validator: serializeInstance.validator,
              ),
            #List => ValueValidator.list(
                optional: serializeInstance.optional,
                validator: serializeInstance.validator,
                childValidator: retrieveValueValidatorFromListGeneric(
                  mirror.type,
                  serializeInstance.serializableType,
                ),
              ),
            #Map => ValueValidator.map(),
            (Symbol _) => ValueValidator.map(
                optional: serializeInstance.optional,
                validator: serializeInstance.validator,
                validators: serializeInstance.serializableType == null
                    ? {}
                    : Serializer(
                        viewModel: serializeInstance.serializableType!.type,
                      ).getValidator(),
              ),
          };
        }
      }
    }
    return validatorMap;
  }

  ValueValidator? retrieveValueValidatorFromListGeneric(
    TypeMirror mirror,
    SerializableType? serializableType,
  ) {
    var typeArgument = mirror.typeArguments.first;

    bool optional = serializableType?.optional ?? false;

    return switch (typeArgument.simpleName) {
      #int => ValueValidator.int(optional: optional),
      #double => ValueValidator.double(optional: optional),
      #String => ValueValidator.string(optional: optional),
      #List => throw ArgumentError('Serializing nested lists is not supported'),
      #Map => ValueValidator.map(
          optional: optional,
        ),
      (Symbol _) => ValueValidator.map(
          optional: optional,
          validators: Serializer(
            viewModel: serializableType?.type ?? Object,
          ).getValidator(),
        ),
    };
  }
}

class Serialize {
  const Serialize({
    this.optional = false,
    this.serializableType,
    this.validator,
  });

  final bool optional;
  final CustomValidator? validator;
  final SerializableType? serializableType;
}

class SerializableType {
  const SerializableType({
    required this.type,
    this.optional = false,
  });

  final Type type;
  final bool optional;
}
