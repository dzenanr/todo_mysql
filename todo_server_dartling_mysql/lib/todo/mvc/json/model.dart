part of todo_mvc;

// http://www.json.org/
// http://jsonformatter.curiousconcept.com/

// lib/dartling/skeleton/json/model.dart

var todoMvcModelJson = r'''
{
    "width":990,
    "lines":[
        
    ],
    "height":580,
    "boxes":[
        {
            "width":80,
            "entry":true,
            "name":"Task",
            "x":162,
            "height":80,
            "y":147,
            "items":[
                {
                    "sequence":20,
                    "name":"title",
                    "init":"",
                    "essential":true,
                    "sensitive":false,
                    "category":"identifier",
                    "type":"String"
                },
                {
                    "sequence":30,
                    "name":"completed",
                    "init":"false",
                    "essential":true,
                    "sensitive":false,
                    "category":"required",
                    "type":"bool"
                },
                {
                    "sequence":40,
                    "name":"updated",
                    "init":"now",
                    "essential":false,
                    "sensitive":false,
                    "category":"required",
                    "type":"DateTime"
                }
            ]
        }
    ]
}
''';