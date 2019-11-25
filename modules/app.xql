xquery version "3.1";

module namespace app="http://dhil.lib.sfu.ca/exist/gpi/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://dhil.lib.sfu.ca/exist/gpi/config" at "config.xqm";
import module namespace collection="http://dhil.lib.sfu.ca/exist/gpi/collection" at "collection.xql";
import module namespace tx='http://dhil.lib.sfu.ca/exist/gpi/transform' at 'transform.xql';
import module namespace console="http://exist-db.org/xquery/console";

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare function app:load-poems($node as node(), $model as map(*)) {
    let $poems := collection:get-poems()
    return map {
        'poems' := $poems,
        'page-size' := $config:poem-page-size,
        'total' := count($poems)
    }
};

declare function app:load-objects($node as node(), $model as map(*)) {
    let $objects := collection:get-objects()
    return map {
        'objects' := $objects,
        'page-size' := $config:object-page-size,
        'total' := count($objects)
    }
};

declare 
    %templates:default("page", 1)
function app:browse-poems($node as node(), $model as map(*), $page as xs:integer) as node()* {
    let $start := $config:poem-page-size * ($page - 1) + 1
    let $end := $start + $config:poem-page-size

    return tx:browse-poems($model('poems')[$start le position() and position() lt $end])
};

declare 
    %templates:default("page", 1)
function app:browse-objects($node as node(), $model as map(*), $page as xs:integer) as node()* {
    let $start := $config:object-page-size * ($page - 1) + 1
    let $end := $start + $config:poem-page-size
    
    return tx:browse-objects($model('objects')[$start le position() and position() lt $end])
};

declare function app:load-poem($node as node(), $model as map(*), $id as xs:string) {
    let $poem := collection:poem($id)
    
    return map {
        'poem-id' := $id,
        'poem' := $poem
    }
};

declare function app:load-object($node as node(), $model as map(*), $id as xs:string) {
    let $object := collection:object($id)
    return map {
        'object-id' := $id,
        'object' := $object
    }
};

declare function app:render-poem($node as node(), $model as map(*)) as node()* {
    let $poem := $model('poem')
    return tx:poem($poem)
};

declare function app:render-object($node as node(), $model as map(*), $id as xs:string) {
    let $object := $model('object')
    return tx:render($object)
};

declare function app:render-poem-references($node as node(), $model as map(*)) as node()* {
    let $poem := $model('poem')
    return tx:poem-references($poem)
};

declare function app:render-object-references($node as node(), $model as map(*)) as node()* {
    ()
};

declare 
    %templates:default("page", 1)
function app:paginate($node as node(), $model as map(*), $page as xs:integer) {
    let $total := $model('total')
    let $page-size := $model('page-size')
    let $span := $config:pager-span
    let $pages := 1 + $total idiv $page-size
    let $start := max((1, $page - $span))
    let $end := min(($pages, $page + $span))
    let $next := min(($pages, $page + 1))
    let $prev := max((1, $page - 1))

    return
      if($pages eq 1) then 
        () 
      else
        <nav>
            <ul class='pagination'>
                <li><a href="?page=1">⇐</a></li>
                <li><a href="?page={$prev}" id='prev-page'>←</a></li>
    
                {
                    for $pn in ($start to $end)
                    let $selected := if($page = $pn) then 'active' else ''
                    return 
                        <li class="{$selected}">
                            <a href="?page={$pn}">{$pn}</a>
                        </li>
                }
    
                <li><a href="?page={$next}" id='next-page'>→</a></li>
                <li><a href="?page={$pages}">⇒</a></li>
            </ul>
        </nav>
};