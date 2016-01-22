# Search by inventory items

## Search by fields' content

You can perform a search for the content of specific fields of an inventory category. 
__Remember: you can only search by fields if you don't perform a search with more than one different category__

To filter by field content, the base of the request is as follows:

    {
      "fields": {
        "id_do_campo": {
          // Filtros aqui
        }
      }
    }

### Filter "greater than"

__Only for numeric fields__

Example:

    {
      "fields": {
        "id_do_campo": {
          "greater_than": 20
        }
      }
    }

In the example presented above, inventory items that have the field value greater than 20 will be returned. (for numeric fields)

### Filter "lesser than"

__Only for numeric fields__

Example:

    {
      "fields": {
        "id_do_campo": {
          "lesser_than": 20
        }
      }
    }

In the example presented above, inventory items that have the field value lesser than 20 will be returned. (for numeric fields)

### Filter "equals to"

__Only for numeric and text fields__

Example:

    {
      "fields": {
        "id_do_campo": {
          "equal_to": "test"
        }
      }
    }

In the example presented above, inventory items that have the field value equals to `test` will be returned.

### Filter "different from"

__Only for numeric and text fields__

Example:

    {
      "fields": {
        "id_do_campo": {
          "different": "test"
        }
      }
    }

In the example presented above, inventory items that have the field value different from `test` will be returned.

### Filter "like"

__Only for numeric and text fields__

Example:

    {
      "fields": {
        "id_do_campo": {
          "like": "test"
        }
      }
    }

In the example presented above, inventory items that have the field value containing `test` will be returned.

### Filter "include"

__Only for fields containing an array as content (e.g.: checkboxes)__

Example:

   ?fields[id_do_campo][includes][0]=1234&fields[id_do_campo][includes][1]=2356

In the example presented above, inventory items that have the field value containing the items selected in the field option with id *1234* and *2356* will be returned.

### Filter "does not include"

__Only for fields containing an array as content (e.g.: checkboxes)__

Example:

   ?fields[id_do_campo][excludes][0]=1234&fields[id_do_campo][excludes][1]=2356

In the example above, inventory items that __DON'T__ have the field value containing the items selected in the field option with id *1234* and *2356* will be returned.