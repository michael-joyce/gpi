xquery version "3.0";

module namespace objecttest="http://dhil.lib.sfu.ca/exist/gpi/test/object";

import module namespace xunit="http://dhil.lib.sfu.ca/exist/xunit/xunit" at "xunit.xql";
import module namespace assert="http://dhil.lib.sfu.ca/exist/xunit/assert" at "assert.xql";

import module namespace object="http://dhil.lib.sfu.ca/exist/gpi/object" at "../../modules/object.xql";

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare
    %xunit:test
function objecttest:root() {
    let $doc := <object xml:id="ida"><objectIdentifier><objectName>Ida</objectName></objectIdentifier><p>A mountain. Or Harrow school.</p></object>

    return (
      assert:equals('object', local-name(object:root($doc))),
      assert:equals('object', local-name(object:root($doc//objectName)))
    )
};

declare
    %xunit:test
function objecttest:id() {
    let $doc := <object xml:id="ida"><objectIdentifier><objectName>Ida</objectName></objectIdentifier><p>A mountain. Or Harrow school.</p></object>

    return (
      assert:equals('ida', object:id($doc)),
      assert:equals('ida', object:id($doc//objectName))
    )
};

declare
    %xunit:test
function objecttest:name() {
    let $doc := <object xml:name="ida"><objectIdentifier><objectName>Ida</objectName></objectIdentifier><p>A mountain. Or Harrow school.</p></object>

    return (
      assert:equals('Ida', object:name($doc)/string()),
      assert:equals('Ida', object:name($doc//objectName)/string())
    )
};

declare
    %xunit:test
function objecttest:description() {
    let $doc := <object xml:description="ida"><objectIdentifier><objectName>Ida</objectName></objectIdentifier><p>A mountain</p></object>

    return (
      assert:equals('A mountain', object:description($doc)/string()),
      assert:equals('A mountain', object:description($doc//objectName)/string())
    )
};

