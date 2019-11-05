xquery version '3.0';

module namespace tx='http://dhil.lib.sfu.ca/exist/gpi/transform';

import module namespace collection="http://dhil.lib.sfu.ca/exist/gpi/collection" at 'collection.xql';

declare namespace xhtml='http://www.w3.org/1999/xhtml';
declare namespace tei='http://www.tei-c.org/ns/1.0';
declare default element namespace 'http://www.w3.org/1999/xhtml';

declare function tx:render($nodes as node()*) as node()* {
    for $node in $nodes
    return
        typeswitch($node)
            case text() return $node
            
            case element(tei:div) return 
                <div class="{$node/@type}">{tx:render($node/node())}</div>
                
            case element(tei:head) return
                <h2>{tx:render($node/node())}</h2>

            case element(tei:lg) return
                <ol>{tx:render($node/node())}</ol>
                
            case element(tei:l) return
                <li>{tx:render($node/node())}</li>
                
            case element(tei:seg) return
                <span class="target" data-reference="{$node/@ana}">{tx:render($node/node())}</span>
                
            case element(tei:ref) return
                <a class="reference" href="{$node/@corresp}">{tx:render($node/node())}</a>
                
            case element(tei:signed) return
                <p class="signed">{tx:render($node/node())}</p>
            
            case element(tei:p) return
                <p>{tx:render($node/node())}</p>
            
            case element(tei:listObject) return
                <dl>{tx:render($node/node())}</dl>
            
            case element(tei:object) return 
                <div id="{$node/@xml:id}">
                    <dt>{tx:render($node//tei:objectName)}</dt>
                    <dd>{tx:render($node/node()[local-name(.) != 'objectIdentifier'])}</dd>
                </div>
            
            case element(tei:objectName) return
                tx:render($node/node())
            
            default return 
                <span class='tx-error'>
                    <span class='node-name'>{ local-name($node) }</span>
                    {tx:render($node/node())}
                </span>
};

declare function tx:poem($nodes as node()*) as node()* {
    tx:render($nodes)
};

declare function tx:references($poem as node()*) as node()* {
    let $references := distinct-values($poem//tei:seg/@ana/string())
    let $list := collection:listObjects($references)
    return tx:render($list)
};
