xquery version "3.1";

module namespace collection="http://dhil.lib.sfu.ca/exist/gpi/collection";

import module namespace config="http://dhil.lib.sfu.ca/exist/gpi/config" at "config.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

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

declare function collection:object($reference as xs:string) as node() {
    let $doc := doc($config:data-root || '/dictionary.xml')
    let $id := substring-after($reference, '#')
    let $object := $doc//tei:object[@xml:id=$id]
    return 
        if ($object) then
            $object
        else 
            <object xmlns="http://www.tei-c.org/ns/1.0" xml:id="error" type="error">
                  <objectIdentifier>
                     <objectName>Error</objectName>
                  </objectIdentifier>
                  <p>The requested object ({$reference} / {$id}) could not be found.</p>
               </object>
};

declare function collection:listObjects($references as xs:string*) as node() {
    <listObject xmlns="http://www.tei-c.org/ns/1.0"> {
        for $reference in $references
            let $object := collection:object($reference)
            order by $object//tei:objectName
            return $object
    } </listObject>
    
};