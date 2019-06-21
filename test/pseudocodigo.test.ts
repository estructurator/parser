import { ast } from '../src/pseudocodigo';

describe('Estructurator - Pseudocodigo', () => {
  
  it('should generate the correct AST', () => {
    const input = `square(x) x * x`;
    const output = [
      {
        "body": [
          {
            "left": {
              "indices": [],
              "name": "x",
              "type": "variable"
            },
            "right": {
              "indices": [],
              "name": "x",
              "type": "variable"
            },
            "type": "product"
          }
        ],
        "name": "square",
        "params": [
          {
            "dimensions": [],
            "name": "x"
          }
        ]
      }
    ];

    const generated = ast(input);

    expect(generated).toEqual(output);
  });

});
