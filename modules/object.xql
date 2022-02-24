xquery version "3.1";

module namespace object = "http://dhil.lib.sfu.ca/exist/gpi/object";

declare default element namespace 'http://www.tei-c.org/ns/1.0';

declare function object:root($node as node()) as node() {
  $node/ancestor-or-self::object
};

declare function object:id($node as node()) as xs:string {
  object:root($node)/@xml:id/string()
};

declare function object:name($node as node()) as node() {
  object:root($node)//objectName
};

declare function object:description($node as node()) as node()* {
  object:root($node)/node()[local-name(.) ne 'objectIdentifier']
};
