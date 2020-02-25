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

declare function tx:head($node as node(), $poem as node()) as node()* {
    tx:render($node/node(), $poem)
};

declare function tx:title($node as node(), $poem as node()) as node() {
    <h1>{tx:render($node/node(), $poem)}</h1>
};

declare function tx:bibl($node as node(), $poem as node()) as node() {
  <cite>{tx:render($node/node(), $poem)}</cite>
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
    <a class="reference" href="{$node/@corresp}" data-gender='{substring-after($node/@ana, '#')}' id="{generate-id($node)}"> { 
        tx:render($node/node(), $poem)
    } </a>
};

declare function tx:signed($node as node(), $poem as node()) as node() {
    <p class="signed">{tx:render($node/node(), $poem)}</p>
};

declare function tx:p($node as node(), $poem as node()) as node() {
    <p>{tx:render($node/node(), $poem)}</p>
};


declare function tx:epigraph($node as node(), $poem as node()) as node() {
    <blockquote class='epigraph'>{tx:render($node/node(), $poem)}</blockquote>
};

declare function tx:cit($node as node(), $poem as node()) as node()* {
    tx:render($node/node()[local-name(.) != 'bibl'], $poem),
    if(exists($node/tei:bibl)) then 
        <cite>{tx:render($node/tei:bibl/node(), $poem)}</cite> 
    else ()     
};

declare function tx:quote($node as node(), $poem as node()) as node() {
    <p>{tx:render($node/node()[local-name(.) != 'bibl'], $poem)}</p>
};

declare function tx:listObject($node as node(), $poem as node()) as node() {
    <aside aria-expanded="true" id="aside">
        
        <div class="aside-heading">
            <h2>Personifications</h2>
            <button id="aside-toggle" class="hamburger hamburger--arrow is-active" type="button" aria-label="Toggle">
            <span class="hamburger-box">
                <span class="hamburger-inner"></span>
            </span>
            <span class="sr-only" aria-hidden="true">Toggle</span>
        </button>
        </div>
        {tx:render($node/node(), $poem)}
    
    </aside>
};


declare function tx:object($node as node(), $poem as node()) as node() {
    <div id="{$node/@xml:id}">
        {
           if ($node[@type]) then attribute{"class"}{$node/@type} else ()
        }
        <h3>{tx:render($node//tei:objectName, $poem)}</h3>
        <a href="../object/view.html?id={$node/@xml:id}" class="record-link">View full record</a>
        { 
            for $node in $node/node()[local-name(.) != 'objectIdentifier']/node()
            return <dd>{tx:render($node, $poem)}</dd>
        }
        
        <div class="references">
        <h4>Personified in this text as: </h4>
        <ul class='references list-inline'> {
            let $refs := $poem//tei:ref[@corresp = ('#' || $node/@xml:id)],
            $genders := distinct-values($refs/@ana)
            return
            for $g in $genders return 
                let $genderRefs := $refs[@ana=$g]/generate-id(.)
                return
             <li>
             
             <a class="genderLink" href="#{$genderRefs[1]}" data-refs="{string-join($genderRefs,' ')}">{
                if ($g = '#f') then 'Female'
                else if ($g = '#m') then 'Male'
                else if ($g = '#n') then 'Neutral'
                else if ($g = '#u') then 'Unknown'
                else ()
             }</a></li>
           (: for $ref in $poem//tei:ref[@corresp= ('#' || $node/@xml:id)]
            return <li> { tx:render($ref, $poem) } </li>:)
        } </ul>
        </div>
        
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

declare function tx:render($nodes as node()*) as node()* {
    tx:render($nodes, <tei:div/>)
};

declare function tx:poem($node as node()) as node()* {
    tx:render($node, $node)
};

declare function tx:poem-references($poem as node()) as node()* {
    let $references := distinct-values($poem//tei:ref/@corresp/string())
    let $list := collection:listObjects($references)
    return tx:render($list, $poem)
};

declare function tx:browse-poems($poems as node()*) as node()* {
<table>
<tbody>
{
        for $poem in $poems
        return 
            <tr>
            <td>
             <a href="view.html?id={$poem/@xml:id}"> { 
                    if(exists($poem//tei:head/tei:title)) then 
                        tx:render($poem//tei:head/tei:title/node()) 
                    else 
                        tx:render($poem//tei:head/node())
                } </a>
            </td>
            <td>
                {
                    if (exists($poem[matches(@xml:id,'^b')])) then 'Byron' else 'Coleridge'
                }
            </td>
            </tr>
    }
</tbody>
</table>
};

declare function tx:browse-objects($objects as node()*) as node()* {
    let $null := <tei:div/>
    
    return
        <dl> {
            for $object in $objects
            return 
            <div>
                    <dt>
                        <a href='view.html?id={$object/@xml:id}'>
                            { tx:render($object/tei:objectIdentifier/node()) }
                        </a>
                    </dt>
                    { 
                        for $node in $object/node()[local-name(.) != 'objectIdentifier']/node()
                        return <dd>{tx:render($node)}</dd>
                    }
                </div>
        } </dl>
};
