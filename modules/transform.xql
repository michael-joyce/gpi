xquery version '3.0';

module namespace tx = 'http://dhil.lib.sfu.ca/exist/gpi/transform';

import module namespace collection = "http://dhil.lib.sfu.ca/exist/gpi/collection" at 'collection.xql';

declare namespace xhtml = 'http://www.w3.org/1999/xhtml';
declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare default element namespace 'http://www.w3.org/1999/xhtml';

declare function tx:div($node as node(), $poem as node()) as node() {
    <div class="{$node/@type}"> { 
        tx:render($node/node(), $poem)
    } </div>
};

declare function tx:head($node as node(), $poem as node()) as node() {
    <h2>{tx:render($node/node(), $poem)}</h2>
};

declare function tx:lg($node as node(), $poem as node()) as node() {
    <ol>{tx:render($node/node(), $poem)}</ol>
};

declare function tx:l($node as node(), $poem as node()) as node() {
    <li>{tx:render($node/node(), $poem)}</li>
};

declare function tx:seg($node as node(), $poem as node()) as node() {
    <span class="target" data-reference="{$node/@ana}"> {
        tx:render($node/node(), $poem)
    }</span>
};

declare function tx:ref($node as node(), $poem as node()) as node() {
    <a class="reference" href="{$node/@corresp}" data-gender='{substring-after($node/@ana, '#')}'> { 
        tx:render($node/node(), $poem)
    } </a>
};

declare function tx:signed($node as node(), $poem as node()) as node() {
    <p class="signed">{tx:render($node/node(), $poem)}</p>
};

declare function tx:p($node as node(), $poem as node()) as node() {
    <p>{tx:render($node/node(), $poem)}</p>
};

declare function tx:listObject($node as node(), $poem as node()) as node() {
    <dl>{tx:render($node/node(), $poem)}</dl>
};

declare function tx:epigraph($node as node(), $poem as node()) as node() {
    <blockquote class='epigraph'>{tx:render($node/node(), $poem)}</blockquote>
};

declare function tx:cit($node as node(), $poem as node()) as node()* {
    tx:render($node/node()[local-name(.) != 'bibl'], $poem),
    if(exists($node/tei:bibl)) then 
        <footer>{tx:render($node/tei:bibl/node(), $poem)}</footer> 
    else ()     
};

declare function tx:quote($node as node(), $poem as node()) as node() {
    <p>{tx:render($node/node()[local-name(.) != 'bibl'], $poem)}</p>
};

declare function tx:object($node as node(), $poem as node()) as node() {
    <div id="{$node/@xml:id}">
        <dt>{tx:render($node//tei:objectName, $poem)}</dt>
        { 
            for $node in $node/node()[local-name(.) != 'objectIdentifier']/node()
            return <dd>{tx:render($node, $poem)}</dd>
        }
        <dd><ul class='references list-inline'> {
            for $ref in $poem//tei:ref[@corresp= '#' || $node/@xml:id]
            return <li> { tx:render($ref, $poem) } </li>
        } </ul></dd>
    </div>
};

declare function tx:objectName($node as node(), $poem as node()) as node() {
    tx:render($node/node(), $poem)
};

declare function local:callback($node as node(), $poem as node()) as node()* {
    let $name := local-name($node)
    let $function := try {
        function-lookup(QName('http://dhil.lib.sfu.ca/exist/gpi/transform', $name), 2)
    } catch * {
        ()
    }
    return if (exists($function)) then 
        $function($node, $poem) 
    else
        <span class='tx-error'>
            <span class='node-name'>{local-name($node)}</span>
            {tx:render($node/node(), $poem)}
        </span>
};

declare function tx:render($nodes as node()*, $poem as node()) as node()* {
    for $node in $nodes
    return
        typeswitch ($node)
            case text() 
                return $node
            case element() 
                return local:callback($node, $poem) 
            case comment() 
                return ()            
            case processing-instruction() 
                return ()
            case attribute() 
                return 
                <span class='tx-error'>
                    <span class='node-name'>Call Error</span>
                    <span>Cannot call render on attribute "@{local-name($node)}".</span>
                </span>

            default return
                <span class='tx-error'>
                    <span class='node-name'>Unknown Type: "{ serialize($node) }"</span>
                    {tx:render($node/node(), $poem)}
                </span>
};

declare function tx:poem($node as node()) as node()* {
    tx:render($node, $node)
};

declare function tx:references($poem as node()) as node()* {
    let $references := distinct-values($poem//tei:ref/@corresp/string())
    let $list := collection:listObjects($references)
    return tx:render($list, $poem)
};
