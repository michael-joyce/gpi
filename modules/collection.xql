xquery version "3.1";

module namespace collection="http://dhil.lib.sfu.ca/exist/gpi/collection";

import module namespace config="http://dhil.lib.sfu.ca/exist/gpi/config" at "config.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function collection:get-poems() as node()* {
    let $collection := collection($config:data-root)
    return $collection//tei:div[@type='poem']
};

declare function collection:get-objects() as node()* {
    let $size := $config:object-page-size
    
    return 
        for $object in doc($config:data-root || '/dictionary.xml')//tei:object
        order by $object/tei:objectIdentifier/tei:objectName
        return $object
};

declare function collection:missing-objects() as node()* {
  let $objectIds := doc($config:data-root || '/dictionary.xml')//tei:object/@xml:id/string()
  let $poems := collection:get-poems()
  
  let $refs := 
    for $ref in $poems//tei:ref
    where 
      (not($ref/@corresp)) or
      (count(index-of($objectIds, substring-after($ref/@corresp/string(), '#'))) eq 0)
      
    return $ref
    
  let $segs := 
    for $seg in $poems//tei:seg
    where 
      (not($seg/@ana)) or
      (count(index-of($objectIds, substring-after($seg/@ana/string(), '#'))) eq 0)
    return $seg
  
  return ($refs, $segs)
};

declare function collection:poem($id as xs:string) as node() {
    let $collection := collection($config:data-root)
    let $poem := $collection//tei:div[@xml:id=$id]
    return 
        if($poem) then
            $poem
        else
            <div xmlns="http://www.tei-c.org/ns/1.0" type="error">
                <p>The requested poem ({$id}) could not be found.</p>
            </div>
};

declare function collection:object($id as xs:string) as node() {
    let $doc := doc($config:data-root || '/dictionary.xml')
    let $object := $doc//tei:object[@xml:id=$id]
    return 
        if ($object) then
            $object
        else 
            <object xmlns="http://www.tei-c.org/ns/1.0" xml:id="error" type="error">
                  <objectIdentifier>
                     <objectName>Error</objectName>
                  </objectIdentifier>
                  <p>The requested object ({$id}) could not be found.</p>
               </object>
};

declare function collection:listObjects($references as xs:string*) as node() {
    <listObject xmlns="http://www.tei-c.org/ns/1.0"> {
        for $reference in $references
            let $id := substring-after($reference, '#')
            let $object := collection:object($id)
            order by $object//tei:objectName
            return $object
    } </listObject>  
};

declare function collection:search-poems($q as xs:string) as node()* {
  if(empty($q) or $q = '') then 
    ()
  else
    for $hit in collection:get-poems()[ft:query(., $q)]
    order by ft:score($hit)
    return $hit
};

declare function collection:references($id) {
()
};