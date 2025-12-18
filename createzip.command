#! /bin/bash

cd /Users/marcoalmeida/Documents/Websites/_local/wordpress-testing/app/public/wp-content/plugins/

zip -r "taxonomy-discounts-woocommerce.zip" "taxonomy-discounts-woocommerce" \
    -x *.DS_Store* \
    -x *.git* \
    -x *.svn* \
    -x *.idea* \
    -x *__MACOSX* \
    -x *_assets* \
    -x *_todo.txt* \
    -x *createzip.command*