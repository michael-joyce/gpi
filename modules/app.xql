xquery version "3.1";

module namespace app="http://dhil.lib.sfu.ca/exist/gpi/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://dhil.lib.sfu.ca/exist/gpi/config" at "config.xqm";
import module namespace collection="http://dhil.lib.sfu.ca/exist/gpi/collection" at "collection.xql";
import module namespace tx='http://dhil.lib.sfu.ca/exist/gpi/transform' at 'transform.xql';

declare function app:load($node as node(), $model as map(*)) {

    let $id := request:get-parameter('id', false())
    let $poem := collection:poem($id)
    
    return map {
        'poem-id' := $id,
        'poem' := $poem
    }
};

declare function app:render-poem($node as node(), $model as map(*)) as node()* {
    let $poem := $model('poem')
    return tx:poem($poem)
};

declare function app:render-references($node as node(), $model as map(*)) as node()* {
    let $poem := $model('poem')
    return tx:references($poem)
};
