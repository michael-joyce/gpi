  
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
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace request="http://exist-db.org/xquery/request";

declare function app:load-breadcrumb($node as node(), $model as map(*)) { 
    map {
        'breadcrumbs' := (
            map {
                'path' := 'index.html',
                'label' := 'Home'
            },
            for $bc in $model('breadcrumb') return $bc
        )
    }
};

declare function app:render-breadcrumb($node as node(), $model as map(*)) {
    let $base := request:get-attribute('exist:controller')
    
    return
        <ul class="breadcrumbs"> {
            for $bc in $model('breadcrumbs')
            return 
                <li> {
                    if($bc('path')) then
                        <a href="{$base}/{$bc('path')}">{$bc('label')}</a>
                    else 
                        <span class="current">{$bc('label')}</span>
                } </li>
        } </ul>
};

(:~
 : Load the complete list of poems into the model. They will be paginated and 
 : displayed elsewhere.
 :)

declare function app:load-poems($node as node(), $model as map(*)) {
    let $poems := collection:get-poems()
    return map {
        'poems' := $poems,
        'page-size' := $config:poem-page-size,
        'total' := count($poems),
        'breadcrumb' := (
            map { 'label' := 'Poems', 'path' := 'poem/index.html' },
            map { 'label' := 'Page ' || request:get-parameter('page', 1) }
        )
    }
};


(:~
 : Load the complete list of objects into the model. They will be paginated and 
 : displayed elsewhere.
 :)
declare function app:load-objects($node as node(), $model as map(*)) {
    let $objects := collection:get-objects()
    return map {
        'objects' := $objects,
        'page-size' := $config:object-page-size,
        'total' := count($objects),
        'breadcrumb' := (
            map { 'label' := 'Personifications', 'path' := 'object/index.html' },
            map { 'label' := 'Page ' || request:get-parameter('page', 1) }
        )
    }
};

(:~
 : Display a one-page list of poems. The peoms come from the model (app:load-poems()) and 
 : are pre-sorted.
 : @todo redo this to use templates:each instead.
 :)
declare 
    %templates:default("page", 1)
function app:browse-poems($node as node(), $model as map(*), $page as xs:integer) as node()* {
    let $start := $config:poem-page-size * ($page - 1) + 1
    let $end := $start + $config:poem-page-size

    return tx:browse-poems($model('poems')[$start le position() and position() lt $end])
};


(:~
 : Display a one-page list of objects. The objects come from the model (app:load-poems()) and 
 : are pre-sorted.
 : @todo redo this to use templates:each instead.
 :)
declare 
    %templates:default("page", 1)
function app:browse-objects($node as node(), $model as map(*), $page as xs:integer) as node()* {
    let $start := $config:object-page-size * ($page - 1) + 1
    let $end := $start + $config:poem-page-size
    
    return tx:browse-objects($model('objects')[$start le position() and position() lt $end])
};

(:~
 : Count the poems stored in the model and return the count.
 :)
declare
function app:count-poems($node as node(), $model as map(*)) as xs:integer {
  count($model('poems'))
};


(:~
 : Count the objects stored in the model and return the count.
 :)
declare
function app:count-objects($node as node(), $model as map(*)) as xs:integer {
  count($model('objects'))
};

(:~
 : Fetch a list of tei:ref and tei:seg tags which do not have corresponding entries
 : in the dictionary and store them in the model.
 : @todo is this function poorly named? 
 :)
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


(:~
 : Fetch the text wrapped by a tei:seg or tei:ref which is stored in the 
 : $model('object').
 : @todo this one is really poorly named.
 :)
declare
  %templates:wrap
function app:object-text($node as node(), $model as map(*)) as xs:string {
  let $object := $model('object')
  return $object//text()
};

(:~
 : Find the poem which contains the tei:ref or tei:seg tag. The tag is stored in
 : $model('object').
 : @todo the bad naming continues. And it should use functions in the poem: namespace.
 :)
declare
  %templates:wrap
function app:object-poem($node as node(), $model as map(*)) as xs:string {
  let $object := $model('object')
  let $poem := $object/ancestor::tei:div[@type='poem']
  let $id := $poem/@xml:id
  return $poem//tei:title/text()
};


(:~
 : Get the referencing string from a tei:ref or tei:seg.
 : @todo this is also a bad name.
 :)
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

(:~
 : Load a poem from the collection and store it in the model.
 :)
declare function app:load-poem($node as node(), $model as map(*), $id as xs:string) {
    let $poem := collection:poem($id)
    
    return map {
        'poem-id' := $id,
        'poem' := $poem,
        'breadcrumb' := (
            map { 'label' := 'Poems', 'path' := 'poem/index.html' },
            map { 'label' := poem:title($poem)/text() }
        )
    }
};


(:~
 : Load a object from the collection and store it in the model.
 :)
declare function app:load-object($node as node(), $model as map(*), $id as xs:string) {
    let $object := collection:object($id)
    return map {
        'object-id' := $id,
        'object' := $object,
        'breadcrumb' := (
            map { 'label' := 'Personifications', 'path' := 'object/index.html' },
            map { 'label' := object:name($object)/text() }
        )
    }
};

(:~
 : Get the poem out of the model and transform it into HTML via the transform module.
 :)
declare function app:render-poem($node as node(), $model as map(*)) as node()* {
    let $poem := $model('poem')
    return tx:poem($poem)
};

(:~
 : Get the object out of the model and transform it into HTML via the transform module.
 :)
declare function app:render-object($node as node(), $model as map(*), $id as xs:string) {
    let $object := $model('object')
    return tx:render($object)
};

(:~
 : Render a list of tei:objects referenced in the tei:seg and tei:ref elements in the poem.
 : @todo does it also work on tei:seg? Not sure.
 :)
declare function app:render-poem-references($node as node(), $model as map(*)) as node()* {
    let $poem := $model('poem')
    return tx:poem-references($poem)
};

(:~
 : Fetch a sequence of poems which reference an object in $model('object') and store
 : the list in the model.
 :)
declare function app:load-object-references($node as node(), $model as map(*)) as map(*) {
  let $object := $model('object')
  let $poems := collection:references(object:id($object))
  return map {
    'poems' := $poems,
    'count' := count($poems)
  }
};

(:~
 : Render a poem title inside a link to the poem.
 :)
declare function app:poem-title($node as node(), $model as map(*)) as node()* {
  let $poem := $model('poem')
  let $title := poem:title($poem)
  let $object := $model('object')
  return 
    <a href="../poem/view.html?id={poem:id($poem)}&amp;object={object:id($object)}">
    {
        if (empty($title))
        then <i>Title Missing</i>
        else normalize-space(string-join($title,''))
    }
    </a>
};

(:~
 : Render an object title in the context of its index page.
 :)
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

(:~
 : Return the count from $model('count') 
 :)
declare function app:count-object-references($node as node(), $model as map(*)) as xs:integer {
  $model('count')
};


(:~
 : Find all the lines in $model('poem') which contain a tei:seg or tei:ref pointing at
 : $model('object'). The lines are rendered by transform.xql into HTML.
 :)
declare 
  %templates:wrap
function app:object-usage($node as node(), $model as map(*)) as node()* {
  let $object := $model('object')
  let $id := '#' || object:id($object)
  let $poem := $model('poem')
  let $lines := $poem//tei:l[ ( .//tei:seg[@ana=$id] | .//tei:ref[@corresp=$id])]
  return tx:render($lines)
};



(:~
 : Perform a search of the poems and store the results in the model.
 :)
declare 
  %templates:default('q', '')
  %templates:default('page', 1)
function app:load-poem-search($node as node(), $model as map(*), $q as xs:string, $page) as map(*) {
  if($q = '') then
    map {
        'breadcrumb' := (
            map { 'label' := 'Poems', 'path' := 'poem/index.html' },
            map { 'label' := 'Search' }            
        )
    }
  else
    let $hits := collection:search-poems($q)
    return
      map {
        'hits' := $hits,
        'page-size' := $config:object-page-size,
        'total' := count($hits),
        'q' := $q,
        'page' := $page,
        'breadcrumb' := (
            map { 'label' := 'Poems', 'path' := 'poem/index.html' },
            map { 'label' := 'Search', 'path' := 'poem/search.html' },
            map { 'label' := $q }
        )
      }
};

(:~
 : Perform a search of the objects and store the results in the model.
 :)
declare 
  %templates:default('q', '')
  %templates:default('page', 1)
function app:load-object-search($node as node(), $model as map(*), $q as xs:string, $page) as map(*) {
  if($q = '') then
    map {
        'breadcrumb' := (
            map { 'label' := 'Personifications', 'path' := 'object/index.html' },
            map { 'label' := 'Search' }            
        )
    }
  else
    let $hits := collection:search-objects($q)
    return
      map {
        'hits' := $hits,
        'page-size' := $config:object-page-size,
        'total' := count($hits),
        'q' := $q,
        'page' := $page,
        'breadcrumb' := (
            map { 'label' := 'Personifications', 'path' := 'object/index.html' },
            map { 'label' := 'Search', 'path' := 'object/search.html' },
            map { 'label' := $q }
        )
      }
};


(:~
 : Render an object name in a link to the object. The object is in $model('hit').
 :)
declare 
function app:search-object-name($node as node(), $model as map(*)) as node()* {
  let $hit := $model('hit')
  let $title := object:name($hit)
  return <a href="view.html?id={object:id($hit)}">{ tx:render($title/node()) }</a>
};



(:~
 : Render a poem title in a link to the poem. The poem is in $model('hit').
 :)
declare 
function app:search-poem-title($node as node(), $model as map(*)) as node()* {
  let $hit := $model('hit')
  let $title := poem:title($hit)
  return <a href="view.html?id={poem:id($hit)}">{ tx:render($title/node()) }</a>
};



(:~
 : Summarize one search it, stored in $model('hit') as a KWIC thing and return it.
 :)
declare function app:search-summary($node as node(), $model as map(*)) as node()* {  
  let $hit := $model('hit')
  return
    kwic:summarize($hit, <config width="40"/>)
};


(:~
 : Return the search term stored in the model as $model('q').
 :)
declare 
  %templates:wrap
function app:search-term($node as node(), $model as map(*)) as xs:string* {
  $model('q')
};

(:~
 : Return the total number of search results, stored in the model as $model('total').
 :)
declare 
  %templates:wrap
function app:search-count($node as node(), $model as map(*)) as xs:integer* {
  $model('total')
};

(:~
 : Create and return a pagination widget. Assumes that $model contains total and page-size 
 : entries. 
 :)
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