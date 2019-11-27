xquery version "3.1";

module namespace poem="http://dhil.lib.sfu.ca/exist/gpi/poem";

declare default element namespace 'http://www.tei-c.org/ns/1.0';

declare function poem:root($node as node()) as node()? {  
  $node/ancestor-or-self::div[@type='poem']
};

declare function poem:head($node as node()) as node()? {
  poem:root($node)/head
};

declare function poem:title($node as node()) as node()? {
  poem:head($node)/title
};

declare function poem:id($node as node()) as xs:string? {
  poem:root($node)/@xml:id/string()
};
