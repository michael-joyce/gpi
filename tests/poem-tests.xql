xquery version "3.0";

module namespace poemtest="http://dhil.lib.sfu.ca/exist/gpi/test/poem";

import module namespace xunit="http://dhil.lib.sfu.ca/exist/xunit/xunit" at "xunit.xql";
import module namespace assert="http://dhil.lib.sfu.ca/exist/xunit/assert" at "assert.xql";

import module namespace poem="http://dhil.lib.sfu.ca/exist/gpi/poem" at "../../modules/poem.xql";

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare
    %xunit:test
function poemtest:root() {
    let $doc := <div xml:id='t1' type='poem'><head><title>Title</title></head><lg><l>Line 1</l><l>Line 2</l></lg></div>
    return (
        assert:equals('div', local-name(poem:root($doc))),
        assert:equals('div', local-name(poem:root($doc//l[1])))
    )
};

declare
    %xunit:test
function poemtest:head() {
    let $doc := <div xml:id='t1' type='poem'><head><title>Title</title></head><lg><l>Line 1</l><l>Line 2</l></lg></div>
    return (
        assert:equals('head', local-name(poem:head($doc))),
        assert:equals('head', local-name(poem:head($doc//l[1])))
    )
};

declare
    %xunit:test
function poemtest:title() {
    let $doc := <div xml:id='t1' type='poem'><head><title>Title</title></head><lg><l>Line 1</l><l>Line 2</l></lg></div>
    return (
        assert:equals('Title', poem:title($doc)/string()),
        assert:equals('Title', poem:title($doc//l[1])/string())
    )
};

declare
    %xunit:test
function poemtest:id() {
    let $doc := <div xml:id='t1' type='poem'><head><title>Title</title></head><lg><l>Line 1</l><l>Line 2</l></lg></div>
    return (
        assert:equals('t1', poem:id($doc)),
        assert:equals('t1', poem:id($doc//l[1]))
    )
};
