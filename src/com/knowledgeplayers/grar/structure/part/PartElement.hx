package com.knowledgeplayers.grar.structure.part;

interface PartElement {
    public function isActivity(): Bool;

    public function isText(): Bool;

    public function isPattern(): Bool;
}
