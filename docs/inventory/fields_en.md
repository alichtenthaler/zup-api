# Fields of inventory categories

A field in the form of an inventory category is an entity that represents a data entered by the user.

## Permissions

You can define which groups can see and edit a specific field through the parameter `permissions`, example on request:

    {
      "sections": [{
        ...
        "fields": [{
          ...
          "permissions": {
            "groups_can_view": "1,4,5",
            "groups_can_edit": "2,5,6"
          }
        }]
      }]
    }

You must pass ids in the format of the example above, separated by commas.

__It is also applied to `sections`__

## Field types

A field must be one of the `kind` available:

    "text" => string
    "integer" => integer
    "decimal" => decimal
    "meters" => integer
    "centimeters" => integer
    "kilometers" => integer
    "years" => integer
    "months" => integer
    "days" => integer
    "hours" => integer
    "seconds" => integer
	"angle" => integer
	"date" => date and time (iso format)
    "time" => time (hour, minutes, seconds)
    "cpf" => string
    "cnpj" => string
    "url" => string,
    "email" => string,
    "images" => array,
    "checkbox" => array,
    "radio" => string

The association describes for which type the content of this field will be converted to, depending on the kind.

For example, if you have a field with `kind` equal to `integer` and you fill it with `2323`. The value of the field in the system will be 2323 (integer), and the content filled in will be validated if it really is a number or not.

For all the described kinds, there is coercion of type, that is, a cast will be done to the required type.

## Validations

Today we have the following validations for the dynamic field:

### maximum

Limits the maximum value of the field content.

### minimum

Limits the minimum value of the field content.

## Fields with special values

### images

Images, accepts an array of objects representing images, example:

    {
      "content": [{
        "content": "conteúdo da imagem encodada em base64 aqui"
      }, ...]
    }

To delete an image that already exists, id must be passed as well as attribute `destroy` equal to true:

    {
      "content": [{
        "id": 12314,
        "destroy": true
      }, ...]
    }

This image id is returned when you get information about the item.

### checkbox and radio

When using a field of type `checkbox` or `radio`, you must pass an array of ids of field choice in the `content`:

    {
      "data": {
        "id do campo": [13, 24]
      }
    }
