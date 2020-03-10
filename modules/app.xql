xquery version "3.1";

module namespace app="http://dhil.lib.sfu.ca/exist/gpi/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://dhil.lib.sfu.ca/exist/gpi/config" at "config.xqm";
import module namespace collection="http://dhil.lib.sfu.ca/exist/gpi/collection" at "collection.xql";
import module namespace tx='http://dhil.lib.sfu.ca/exist/gpi/transform' at 'transform.xql';
import module namespace poem='http://dhil.lib.sfu.ca/exist/gpi/poem' at 'poem.xql';
import module namespace object='http://dhil.lib.sfu.ca/exist/gpi/object' at 'object.xql';

import module namespace kwic="http://exist-db.org/xquery/kwic";

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

declare
function app:count-objects($node as node(), $model as map(*)) as xs:integer {
  count($model('objects'))
};

declare 
  %templates:wrap
function app:load-missing-objects($node as node(), $model as map(*)) as map(*) {
  let $missing := collection:missing-objects()
  let $refs := 
    for $object in $missing
    where local-name($object) = 'ref'
    return $object
    
  let $segs := 
    for $object in $missing
    where local-name($object) = 'seg'
    return $object
    
    return map {
      'refs' := $refs,
      'segs' := $segs
    }
};

declare
  %templates:wrap
function app:object-text($node as node(), $model as map(*)) as xs:string {
  let $object := $model('object')
  return $object//text()
};

declare
  %templates:wrap
function app:object-poem($node as node(), $model as map(*)) as xs:string {
  let $object := $model('object')
  let $poem := $object/ancestor::tei:div[@type='poem']
  let $id := $poem/@xml:id
  return $poem//tei:title/text()
};

declare
  %templates:wrap
function app:object-reference($node as node(), $model as map(*)) as xs:string* {
  let $object := $model('object')
  return
    switch(local-name($object)) 
      case 'ref'
        return $object/@corresp/string()
      case 'seg'
        return $object/@ana/string()
      default
        return local-name($object)
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

declare function app:load-object-references($node as node(), $model as map(*)) as map(*) {
  let $object := $model('object')
  let $poems := collection:references(object:id($object))
  return map {
    'poems' := $poems,
    'count' := count($poems)
  }
};

declare function app:poem-title($node as node(), $model as map(*)) as node()* {
  let $poem := $model('poem')
  let $object := $model('object')
  return <a href="../poem/view.html?id={poem:id($poem)}&amp;object={object:id($object)}">{string-join(poem:title($poem)/descendant::text(),'')}</a>
};

declare function app:object-title($node as node(), $model as map(*)) as node()*{
    let $object := $model('object')
    let $name := object:name($object)
    return
    <div class="row object-title">
            <div class="col-sm-12">
                <div class="page-header">
                    <h1>{tx:render($name/node())}</h1>
                </div>
            </div>
        </div>
};

declare function app:count-object-references($node as node(), $model as map(*)) as xs:integer {
  $model('count')
};


declare 
  %templates:wrap
function app:object-usage($node as node(), $model as map(*)) as node()* {
  let $object := $model('object')
  let $id := '#' || object:id($object)
  let $poem := $model('poem')
  let $lines := $poem//tei:l[ ( .//tei:seg[@ana=$id] | .//tei:ref[@corresp=$id])]
  return tx:render($lines)
};

declare 
  %templates:default('q', '')
  %templates:default('page', 1)
function app:load-poem-search($node as node(), $model as map(*), $q as xs:string, $page) as map(*) {
  if($q = '') then
    map {}
  else
    let $hits := collection:search-poems($q)
    return
      map {
        'hits' := $hits,
        'page-size' := $config:object-page-size,
        'total' := count($hits),
        'q' := $q,
        'page' := $page
      }
};

declare 
function app:search-object-name($node as node(), $model as map(*)) as node()* {
  let $hit := $model('hit')
  let $title := object:name($hit)
  return <a href="view.html?id={object:id($hit)}">{ tx:render($title/node()) }</a>
};

declare 
  %templates:default('q', '')
  %templates:default('page', 1)
function app:load-object-search($node as node(), $model as map(*), $q as xs:string, $page) as map(*) {
  if($q = '') then
    map {}
  else
    let $hits := collection:search-objects($q)
    return
      map {
        'hits' := $hits,
        'page-size' := $config:object-page-size,
        'total' := count($hits),
        'q' := $q,
        'page' := $page
      }
};

declare 
function app:search-poem-title($node as node(), $model as map(*)) as node()* {
  let $hit := $model('hit')
  let $title := poem:title($hit)
  return <a href="view.html?id={poem:id($hit)}">{ tx:render($title/node()) }</a>
};

declare function app:search-summary($node as node(), $model as map(*)) as node()* {  
  let $hit := $model('hit')
  return
    kwic:summarize($hit, <config width="40"/>)
};


declare 
  %templates:wrap
function app:search-term($node as node(), $model as map(*)) as xs:string* {
  $model('q')
};

declare 
  %templates:wrap
function app:search-count($node as node(), $model as map(*)) as xs:integer* {
  $model('total')
};

declare 
    %templates:default("page", 1)
    %templates:default("q", '')
function app:paginate($node as node(), $model as map(*), $page as xs:integer, $q as xs:string) {
    let $total := $model('total')
    let $page-size := $model('page-size')
    let $span := $config:pager-span
    let $pages := 1 + $total idiv $page-size
    let $start := max((1, $page - $span))
    let $end := min(($pages, $page + $span))
    let $next := min(($pages, $page + 1))
    let $prev := max((1, $page - 1))

    let $query-param := if($q) then "&amp;q=" || $q else ""

    return
      if(empty($pages) or $pages le 1) then 
        () 
      else
        <nav>
            <ul class='pagination'>
                <li><a href="?page=1{$query-param}">⇐</a></li>
                <li><a href="?page={$prev}{$query-param}" id='prev-page'>←</a></li>
    
                {
                    for $pn in ($start to $end)
                    let $selected := if($page = $pn) then 'active' else ''
                    return 
                        <li class="{$selected}">
                            <a href="?page={$pn}{$query-param}">{$pn}</a>
                        </li>
                }
    
                <li><a href="?page={$next}{$query-param}" id='next-page'>→</a></li>
                <li><a href="?page={$pages}{$query-param}">⇒</a></li>
            </ul>
        </nav>
};