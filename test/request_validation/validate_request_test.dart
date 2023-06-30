import 'package:poison/poison.dart';
import 'package:test/test.dart';

void main() {
  group('ValueValidator', () {
    test('should return valid json', () {
      var expected = {
        'first': ['String'],
        'second': {
          'key1': 'double',
          'key2': 'int',
        },
        'third': {
          'nested': {
            'deeper': [
              {'further': 'int'},
            ],
          },
        },
      };

      var validators = <String, ValueValidator>{
        'first': ValueValidator.list(
          childValidator: ValueValidator.string(),
        ),
        'second': ValueValidator.map(
          validators: {
            'key1': ValueValidator.double(),
            'key2': ValueValidator.int(),
          },
        ),
        'third': ValueValidator.map(
          validators: {
            'nested': ValueValidator.map(
              validators: {
                'deeper': ValueValidator.list(
                  childValidator: ValueValidator.map(
                    validators: {
                      'further': ValueValidator.int(),
                    },
                  ),
                )
              },
            ),
          },
        ),
      };

      expect(validators.asJson(), equals(expected));
    });
  });
}
